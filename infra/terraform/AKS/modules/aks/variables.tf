variable "location" {
  description = "Azure location where the AKS Cluster will be deployed"
}

variable "resource_group_name" {
  description = "Name of the resource group in which the AKS Cluster will be assigned"
}

variable "name" {
  description = "Name of the AKS Cluster"
  default     = "aks"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes"
  default     = "1.19.3"
}

variable "dns_prefix" {
  description = "DNS prefix specified for the cluster FQDN"
  default     = "aks"
}

variable "node_count" {
  description = "Initial number of nodes which should exist in the default Node Pool"
  default     = 2
}

variable "vm_size" {
  description = "Size of the Virtual Machines created by the Node Pool"
  default     = "Standard_D2_v2"
}