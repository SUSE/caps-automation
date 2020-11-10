output "account_name" {
  value = azurerm_storage_account.account.name
}

output "access_key" {
  value = azurerm_storage_account.account.primary_access_key
}

output "container_name" {
  value = azurerm_storage_container.container.name
}