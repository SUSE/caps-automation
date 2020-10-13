terraform {
  backend "azurerm" {
    storage_account_name = "ecosystemci"
    container_name       = "tfstate"
    key                  = "ci.terraform.tfstate"
  }
}