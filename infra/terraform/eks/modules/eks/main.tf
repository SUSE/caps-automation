resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  az_names = data.aws_availability_zones.azs.names
}

resource "aws_default_subnet" "default_subnets" {
  for_each = toset(local.az_names)

  availability_zone = each.value
}

provider "kubernetes" {
  config_path      = module.eks.kubeconfig_filename
  load_config_file = true
  version          = "~> 1.11"
}

module "eks" {
  source             = "terraform-aws-modules/eks/aws"
  cluster_name       = var.name
  cluster_version    = var.kubernetes_version
  write_kubeconfig   = true
  config_output_path = "./kubeconfig"
  vpc_id             = aws_default_vpc.default.id
  subnets            = values(aws_default_subnet.default_subnets)[*].id

  tags = {
    Environment = "ecosystem - ${var.name}"
  }

  worker_groups = [
    {
      name                 = "group-1"
      instance_type        = var.vm_size
      asg_desired_capacity = var.node_count
      spot_price           = var.spot_price
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
    }
  ]
}

# TODO: Configure EFS storageclass
# resource "aws_efs_file_system" "efs" {
#   creation_token = "${var.name}-storageclass"

#   tags = {
#     Environment = "ecosystem - ${var.name}"
#   }
# }

# resource "aws_security_group" "allow_nfs" {
#   name        = "${terraform.workspace}-allow_nfs"
#   description = "Allow NFS inbound traffic"
#   vpc_id      = aws_default_vpc.default.id

#   ingress {
#     description = "NFS from VPC"
#     from_port   = 2049
#     to_port     = 2049
#     protocol    = "tcp"
#     cidr_blocks = [aws_default_vpc.default.cidr_block]
#   }

#   tags = {
#     Name = "allow_nfs"
#   }
# }

# resource "aws_efs_mount_target" "efs_mounts" {
#   for_each = aws_default_subnet.default_subnets

#   file_system_id = aws_efs_file_system.efs.id
#   subnet_id = each.value.id
#   security_groups = [aws_security_group.allow_nfs.id]
# }