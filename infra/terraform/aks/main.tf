provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${terraform.workspace}-${var.resource_group_name}"
  location = var.location
}

module "aks" {
  source = "./modules/aks"
  count  = var.k8s_enabled ? 1 : 0

  name                = "${terraform.workspace}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = terraform.workspace
}

module "postgresql" {
  source = "./modules/postgresql"
  count  = var.db_enabled ? 1 : 0

  name                = "${terraform.workspace}-postgresql"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  databases           = var.db_databases
}

module "blob_storage" {
  source = "./modules/blob_storage"
  count  = var.object_storage_enabled ? 1 : 0

  account_name        = "${terraform.workspace}accountecosystemci"
  container_name      = "${terraform.workspace}-container"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "redis_cache" {
  source = "./modules/redis_cache"
  count  = var.redis_enabled ? 1 : 0

  name                = "${terraform.workspace}-redis"
  enable_non_ssl_port = true
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
