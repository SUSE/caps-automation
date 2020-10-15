variable "resource_group_name" {
  default = "ecosystem-ci"
}

variable "location" {
  default = "Germany West Central"
}

variable "k8s_enabled" {
  default = true
}

variable "db_enabled" {
  default = true
}

variable "db_databases" {
  default = ["registry", "notary_server", "notary_signer"]
}

variable "object_storage_enabled" {
  default = true
}

variable "redis_enabled" {
  default = true
}
