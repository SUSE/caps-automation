output "fqdn" {
  value = azurerm_postgresql_server.postgresql.fqdn
}

output "login" {
  value = "${azurerm_postgresql_server.postgresql.administrator_login}@${azurerm_postgresql_server.postgresql.name}"
}

output "password" {
  value = azurerm_postgresql_server.postgresql.administrator_login_password
}