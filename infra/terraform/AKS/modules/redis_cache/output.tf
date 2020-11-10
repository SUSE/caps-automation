output "hostname" {
  value = azurerm_redis_cache.redis.hostname
}

output "password" {
  value = azurerm_redis_cache.redis.primary_access_key
}