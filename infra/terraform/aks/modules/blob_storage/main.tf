resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_storage_account" "account" {
  name                     = "${var.account_name_prefix}${lower(random_id.storage_account.hex)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "ecosystem-ci"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.account.name
  container_access_type = "private"
}