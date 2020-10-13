variable "location" {
  description = "Azure location where the Redis Cache will be deployed"
}

variable "resource_group_name" {
  description = "Name of the resource group in which the Redis Cache will be assigned"
}

# NOTE: the Name used for Redis needs to be globally unique
variable "name" {
  description = "Name of the Redis Cache deployment"
}

variable "enable_non_ssl_port" {
  description = "Enable the non-SSL port (6379)"
}