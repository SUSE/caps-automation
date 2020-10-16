variable "region" {
  description = "AWS region where the EKS Cluster will be deployed"
}

variable "name" {
  description = "Name of the EKS Cluster"
  default     = "eks"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes"
  default     = "1.17"
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
  default     = "t3a.small"
  #default     = "a1.medium"
}

variable "spot_price" {
  description = "Spot price for worker nodes"
  default     = "0.03"
}
