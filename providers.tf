provider "azuread" {
  tenant_id = var.tenant_id
  environment = "usgovernment"
}

provider "azurerm" {
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  environment = "usgovernment"
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  
  required_version = ">= 1.1.0"
}