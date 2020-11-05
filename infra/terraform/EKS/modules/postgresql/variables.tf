variable "region" {
  description = "AWS region where the PostgreSQL Server will be deployed"
}

variable "name" {
  description = "Name of the AWS Aurora deployment"
  default     = "harbordb"
}

variable "administrator_login" {
  description = "Login to authenticate to PostgreSQL Server"
  default     = "ecosystem"
}

variable "postgresql_version" {
  description = "PostgreSQL Server version to deploy"
  default     = "11"
}

variable "databases" {
  description = "List of databases to be created on the PostgresSQL Server"
}
