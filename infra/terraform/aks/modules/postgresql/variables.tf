variable "location" {
  description = "Azure location where the PostgreSQL Server will be deployed"
}

variable "resource_group_name" {
  description = "Name of the resource group in which the PostgreSQL Server will be assigned"
}

variable "name" {
  description = "Name of the Azure-PostgreSQL deployment"
  default     = "az-psql"
}

variable "administrator_login" {
  description = "Login to authenticate to PostgreSQL Server"
  default     = "ecosystem"
}

variable "postgresql_version" {
  description = "PostgreSQL Server version to deploy"
  default     = "11"
}

variable "sku_name" {
  description = "PostgreSQL SKU Name"
  default     = "B_Gen5_1"
}

variable "storage_mb" {
  description = "PostgreSQL Storage in MB"
  default     = "5120"
}

variable "databases" {
  description = "List of databases to be created on the PostgresSQL Server"
}