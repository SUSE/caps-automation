variable "region" {
  description = "AWS region where the Redis Cache will be deployed"
}

# NOTE: the Name used for Redis needs to be globally unique
variable "name" {
  description = "Name of the Redis Cache deployment"
}
