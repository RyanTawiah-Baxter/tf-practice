terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}

provider "azurerm" {
    subscription_id = "d8634ddc-d384-4cc3-b216-a71eef2cc982"
    tenant_id = "5ce25efb-1b14-40fa-a68e-18658b73d3b5"
    client_id = "dc90d1ed-5dcc-40b9-a69f-608053243fb5"
    client_secret = "uqC8Q~BLmkxd5axXPO~TS3GIKCjYcfrsMEBcRddG"
    features {}
}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "appstorageaccunt001" {
  name                     = "appstorageaccunt001"
  resource_group_name      = "app-rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  depends_on = [ azurerm_resource_group.appgrp ]

  tags = {
    environment = "test"
  }
}

resource "azurerm_storage_container" "appdata" {
  name                  = "appdata"
  storage_account_name  = "appstorageaccunt001"
  container_access_type = "blob"
  depends_on = [ azurerm_storage_account.appstorageaccunt001 ]
}

resource "azurerm_storage_blob" "maintf" {
  name                   = "main.tf"
  storage_account_name   = "appstorageaccunt001"
  storage_container_name = "appdata"
  type                   = "Block"
  source                 = "main.tf"
  depends_on = [ azurerm_storage_container.appdata ]
}