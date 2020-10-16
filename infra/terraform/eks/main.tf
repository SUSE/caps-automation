terraform {
  required_version = ">= 0.13.0"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
}

module "eks" {
  source = "./modules/eks"

  name        = "${terraform.workspace}-eks"
  dns_prefix  = terraform.workspace
  region      = var.region
}

module "postgresql" {
  source = "./modules/postgresql"
  count  = var.db_enabled ? 1 : 0

  name      = "${terraform.workspace}db"
  region    = var.region
  databases = var.db_databases
}

module "blob_storage" {
  source = "./modules/blob_storage"
  count  = var.object_storage_enabled ? 1 : 0

  account_name_prefix = substr(terraform.workspace, 0, 4)
  container_name      = "${terraform.workspace}-container"
  region              = var.region
}

module "redis_cache" {
  source = "./modules/redis_cache"
  count  = var.redis_enabled ? 1 : 0

  name                = "${terraform.workspace}-redis"
  region              = var.region
}
