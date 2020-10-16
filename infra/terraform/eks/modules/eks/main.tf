resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_a" {
  availability_zone = "${var.region}a"
}

resource "aws_default_subnet" "default_b" {
  availability_zone = "${var.region}b"
}

resource "aws_default_subnet" "default_c" {
  availability_zone = "${var.region}c"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
   name = module.eks.cluster_id
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  load_config_file = false
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  version = "~> 1.11"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.name
  cluster_version = var.kubernetes_version
  vpc_id          = aws_default_vpc.default.id
  subnets         = [aws_default_subnet.default_a.id,
                     aws_default_subnet.default_b.id,
                     aws_default_subnet.default_c.id]

  tags = {
    Environment = "ecosystem - ${var.name}"
  }

  worker_groups = [
    {
      name = "group-1"
      instance_type = var.vm_size
      asg_desired_capacity = var.node_count
      spot_price = var.spot_price
      kubelet_extra_args  = "--node-labels=node.kubernetes.io/lifecycle=spot"
    }
  ]
}

resource "kubernetes_storage_class" "persistent" {
  metadata {
    name = "persistent"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Delete"
  allow_volume_expansion = true
}

#resource "null_resource" "kubeconfig-and-ingress" {
#  depends_on = [module.eks]
#
#  provisioner "local-exec" {
#    command = <<EOT
#    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.40.2/deploy/static/provider/aws/deploy.yaml
#    # kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.8/docs/examples/alb-ingress-controller.yaml
#  EOT
#
#  environment = {
#      KUBECONFIG = "./kubeconfig_${var.name}"
#    }
#  }
#}
