
# Remote state with terraform

terraform {
 required_providers {
   
   azurerm = {
    source = "hashicorp/azurerm"
    version = "=2.46.0"

   }
 }

}

# Azure Provider

provider "azurerm" {
  features {}
  subscription_id = "${var.az_subscription_id}"
  tenant_id       = "${var.az_tenant_id}"
  client_id       = "${var.provider_client_id}"
  client_secret   = "${var.provider_client_secret}"
}


