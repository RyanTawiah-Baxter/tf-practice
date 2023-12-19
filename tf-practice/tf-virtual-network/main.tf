locals {
  resource_group_name = "app-grp"
  location = "eastus"
  admin_username = base64encode( "ryantawiah" )
  admin_password = base64encode( "TerraformLover123!" )
  virtual_network= {
    name = "appnetwork"
    address_space= "10.0.0.0/16"
  }
  subnets =[
    {
      name = "subnetA"
      address_prefix= "10.0.0.0/24"
    },
    {
      name = "subnetB"
      address_prefix= "10.0.1.0/24"
    }
  ]
}

#################################################################

resource "azurerm_resource_group" "apprg" {
  name     = local.resource_group_name
  location = local.location
}

#################################################################

resource "azurerm_virtual_network" "appnetwork" {
  name     = local.virtual_network.name
  location = local.location
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]
   depends_on = [
     azurerm_resource_group.apprg
   ]
  }

#################################################################

  resource "azurerm_subnet" "subnetA" {
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[0].address_prefix]
  depends_on = [
    azurerm_virtual_network.appnetwork
  ]
}

resource "azurerm_subnet" "subnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[1].address_prefix]
  depends_on = [
    azurerm_virtual_network.appnetwork
  ]
}

#################################################################

resource "azurerm_network_interface" "appinterface" {
  name                = "appinterface"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_subnet.subnetA
  ]
}

#################################################################

resource "azurerm_public_ip" "appip" {
  name                = "app-ip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
 depends_on = [
   azurerm_resource_group.apprg
 ]
}

#################################################################

resource "azurerm_network_security_group" "appnetworksg" {
  name                = "app-network-sg"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
    azurerm_resource_group.apprg
  ]
}

#################################################################

resource "azurerm_subnet_network_security_group_association" "appnsglink" {
  subnet_id                 = azurerm_subnet.subnetA.id
  network_security_group_id = azurerm_network_security_group.appnetworksg.id
}

################################################################# 

resource "azurerm_windows_virtual_machine" "appvm" {
  name                = "appvm"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_D2S_v3"
  admin_username      = local.admin_username
  admin_password      = local.admin_password
  network_interface_ids = [
    azurerm_network_interface.appinterface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2023-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.appinterface,
    azurerm_resource_group.apprg
  ]
}