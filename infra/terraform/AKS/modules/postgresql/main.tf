resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "_%@"
}

resource "azurerm_postgresql_server" "postgresql" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.administrator_login
  administrator_login_password = random_password.db_password.result

  sku_name          = var.sku_name
  version           = var.postgresql_version
  storage_mb        = var.storage_mb
  auto_grow_enabled = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = {
    environment = "ecosystem-ci"
  }
}

resource "azurerm_postgresql_database" "databases" {
  for_each = toset(var.databases)

  name                = each.value
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgresql.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}


resource "azurerm_postgresql_firewall_rule" "az-services" {
  name                = "${var.name}-az-services"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgresql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}