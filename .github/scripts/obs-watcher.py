#!/usr/bin/python3

# This script was copied from the openSUSE/openSUSE-release-tools project
# with some modifications to send github workflow_dispatch events.
# The original script is available at: 
# https://github.com/openSUSE/openSUSE-release-tools/blob/master/gocd/rabbit-repoid.py

import argparse
import datetime
import glob
import json
import logging
import os.path
import requests
import time

import osc
from osc.core import http_GET, makeurl

from osclib.core import target_archs
from lxml import etree as ET

from urllib.error import HTTPError
from osclib.PubSubConsumer import PubSubConsumer

class Listener(PubSubConsumer):
    def __init__(self, apiurl, git_repository, git_pat, amqp_prefix, namespaces):
        super(Listener, self).__init__(amqp_prefix, logging.getLogger(__name__))
        self.apiurl = apiurl
        self.git_repository = git_repository
        self.git_pat = git_pat
        self.amqp_prefix = amqp_prefix
        self.namespaces = namespaces
        self.repositories_to_check = []

    def interval(self):
        if len(self.repositories_to_check):
            return 5
        return super(Listener, self).interval()

    def still_alive(self):
        self.check_some_repos()
        super(Listener, self).still_alive()

    def routing_keys(self):
        return [self.amqp_prefix + '.obs.repo.build_finished']

    def check_arch(self, project, repository, architecture):
        url = makeurl(self.apiurl, [
                      'build', project, repository, architecture], {'view': 'status'})
        root = ET.parse(http_GET(url)).getroot()
        if root.get('code') == 'finished':
            buildid = root.find('buildid')
            if buildid is not None:
                return buildid.text

    def check_all_archs(self, project, repository):
        ids = {}
        try:
            archs = target_archs(self.apiurl, project, repository)
        except HTTPError:
            return None
        for arch in archs:
            repoid = self.check_arch(project, repository, arch)
            if not repoid:
                self.logger.info('{}/{}/{} not yet done'.format(project, repository, arch))
                return None
            ids[arch] = repoid
        self.logger.info('All of {}/{} finished'.format(project, repository))
        return ids

    def is_part_of_namespaces(self, project):
        for namespace in self.namespaces:
            if project.startswith(namespace):
                return True

    def start_consuming(self):
        # now we are (re-)connected to the bus and need to fetch the
        # initial state
        for namespace in self.namespaces:
            for state in glob.glob('{}*.yaml'.format(namespace)):
                state = state.replace('.yaml', '')
                # split
                project, repository = state.split('_-_')
                self.repositories_to_check.append([project, repository])
        self.check_some_repos()
        super(Listener, self).start_consuming()

    def check_some_repos(self):
        count = 0
        limit = 15
        while len(self.repositories_to_check):
            project, repository = self.repositories_to_check.pop()
            self.logger.info(f"Check repo {project}/{repository}")
            self.update_repo(project, repository)
            count += 1
            if count >= limit:
                return

    def dispatch_event(self, project, repository):
        headers = {"Accept": "application/vnd.github.v3+json",
                "Authorization": f"token {self.git_pat}"}
        version = project.split(":")[-1]
        url = f"https://api.github.com/repos/{self.git_repository}/actions/workflows/registry-{version}.yml/dispatches"
        inputs = {"project": project, "repository": repository}
        data = {"ref": "master", "inputs": inputs}
        self.logger.info(f"Dispatching event: {data}")
        response = requests.post(url, headers=headers, json=data)
        if response.ok:
            self.logger.info(f"Event dispatched to {self.git_repository}")
        else:
            self.logger.error(response.content)

    def update_repo(self, project, repository):
        ids = self.check_all_archs(project, repository)
        if not ids:
            return
        for arch in sorted(ids.keys()):
            # Dispatch events for the containers and charts repository and
            # only for the x86_64 architecture so the jobs are not
            # triggered twice.
            if (arch in ["x86_64"] and repository in ['containers', 'charts']):
              self.dispatch_event(project, f"{repository}-{arch}")

    def on_message(self, unused_channel, method, properties, body):
        self.logger.debug("on_message")
        self.check_some_repos()
        self.acknowledge_message(method.delivery_tag)
        try:
            body = json.loads(body)
        except ValueError:
            return
        if method.routing_key.endswith('.obs.repo.build_finished'):
            if not self.is_part_of_namespaces(body['project']):
                return
            self.restart_timer()
            self.logger.info('Repo finished event: {}/{}/{}'.format(body['project'], body['repo'], body['arch']))
            self.update_repo(body['project'], body['repo'])
        else:
            self.logger.warning(
                'unknown rabbitmq message {}'.format(method.routing_key))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Watch for projects/repositories that finished building and send a repository_dispatch event to github')
    parser.add_argument('--apiurl', '-A', type=str, help='API URL of OBS')
    parser.add_argument('-d', '--debug', action='store_true', default=False,
                        help='enable debug information')
    parser.add_argument('--repository', '-r', type=str, help='github repository (e.g. SUSE/registry)')
    parser.add_argument('--token', '-t', type=str, help='github PA Token')
    parser.add_argument('namespaces', nargs='*', help='namespaces to wait for')

    args = parser.parse_args()

    osc.conf.get_config(override_apiurl=args.apiurl)
    osc.conf.config['debug'] = args.debug

    apiurl = osc.conf.config['apiurl']
    git_repository = args.repository
    git_pat = args.token

    if apiurl.endswith('suse.de'):
        amqp_prefix = 'suse'
    else:
        amqp_prefix = 'opensuse'

    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)

    listener = Listener(apiurl, git_repository, git_pat, amqp_prefix, args.namespaces)

    try:
        listener.run(86400)
    except KeyboardInterrupt:
        listener.stop()
