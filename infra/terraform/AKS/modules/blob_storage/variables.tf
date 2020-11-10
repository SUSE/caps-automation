variable "location" {
  description = "Azure location where the blob storage will be deployed"
}

variable "resource_group_name" {
  description = "Name of the resource group in which the blob storage will be assigned"
}

variable "account_name_prefix" {
  description = "Prefix for generating the storage account name"
}

variable "container_name" {
  description = "Name of the blob storage account"
}
