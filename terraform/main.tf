resource "azurerm_resource_group" "test" {
  name     = "rg-terraform-test"
  location = "eastus"
}

data "azurerm_storage_account" "tfstate" {
  name                = "sttfstate45353432404"
  resource_group_name = "rg-az-devsecops-platform"
}


module "network" {
  source              = "./modules/network"
  resource_group_name = "rg-az-devsecops-platform"
  location            = "eastus"

  storage_account_id  = data.azurerm_storage_account.tfstate.id
}