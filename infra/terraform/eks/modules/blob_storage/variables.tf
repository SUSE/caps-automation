variable "region" {
  description = "AWS region where the blob storage will be deployed"
}

variable "account_name_prefix" {
  description = "Prefix for generating the storage account name"
}

variable "container_name" {
  description = "Name of the blob storage account"
}
