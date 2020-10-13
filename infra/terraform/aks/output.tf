# The join is required to get a "scalar" value as the module output returns
# a list because of the way they can be dynamically enabled/disabled. See:
# https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
output "kubeconfig" {
  value     = join("", module.aks.*.kubeconfig)
  sensitive = true
}

output "db_fqdn" {
  value     = join("", module.postgresql.*.fqdn)
  sensitive = true
}

output "db_login" {
  value     = join("", module.postgresql.*.login)
  sensitive = true
}

output "db_password" {
  value     = join("", module.postgresql.*.password)
  sensitive = true
}

output "object_storage_account_name" {
  value     = join("", module.blob_storage.*.account_name)
  sensitive = true
}

output "object_storage_access_key" {
  value     = join("", module.blob_storage.*.access_key)
  sensitive = true
}

output "object_storage_container_name" {
  value     = join("", module.blob_storage.*.container_name)
  sensitive = true
}

output "redis_fqdn" {
  value     = join("", module.redis_cache.*.hostname)
  sensitive = true
}

output "redis_password" {
  value     = join("", module.redis_cache.*.password)
  sensitive = true
}

output "type" {
  value = "azure"
}