variable "region" {
  description = "AWS region where the EKS Cluster will be deployed"
}

variable "name" {
  description = "Name of the EKS Cluster"
  default     = "eks"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes"
  default     = "1.18"
}

variable "dns_prefix" {
  description = "DNS prefix specified for the cluster FQDN"
  default     = "eks"
}

variable "node_count" {
  description = "Initial number of worker nodes"
  default     = 2
}

variable "vm_size" {
  description = "Size of the Virtual Machines created by the Node Pool"
  default     = "t3a.medium"
  # see max number of pods per node type:
  # https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
}

variable "spot_price" {
  description = "Spot price for worker nodes"
  default     = "0.03"
}
