terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}
#################################################################

provider "azurerm" {
    subscription_id = "d8634ddc-d384-4cc3-b216-a71eef2cc982"
    tenant_id = "5ce25efb-1b14-40fa-a68e-18658b73d3b5"
    client_id = "dc90d1ed-5dcc-40b9-a69f-608053243fb5"
    client_secret = var.client_secret
    features {}
}

#################################################################
