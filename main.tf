provider "azurerm" {
    version                         = "2.4.0"
    features {}
}

resource "azurerm_resource_group" "test_rg" {
  name                              = var.rg_name
  location                          = var.rg_location
}

resource "azurerm_virtual_network" "test_vnet"{
  name                              = "${var.resource_prefix}-vnet"
  location                          = var.rg_location
  resource_group_name               = azurerm_resource_group.test_rg.name
  address_space                     = [var.vnet_address_space]
}

resource "azurerm_subnet" "test_subnet"{
  name                              = "${var.resource_prefix}-subnet"
  resource_group_name               = azurerm_resource_group.test_rg.name
  virtual_network_name              = azurerm_virtual_network.test_vnet.name
  address_prefix                    = var.subnet_address_prefix
}

resource "azurerm_network_interface" "test_nic"{
  name                              = "${var.server_name}-nic"
  location                          = var.rg_location
  resource_group_name               = azurerm_resource_group.test_rg.name

  ip_configuration {
      name                          = "${var.server_name}-ip"
      subnet_id                     = azurerm_subnet.test_subnet.id
      private_ip_address_allocation = "dynamic"
  }  
}

resource "azurerm_public_ip" "test_public_ip"{
  name                              = "${var.server_name}-public-ip"
  location                          = var.rg_location
  resource_group_name               = azurerm_resource_group.test_rg.name
  allocation_method                 = var.environment == "production" ? "Static" : "Dynamic"
}

resource "azurerm_network_security_group" "test_nsg"{
  name                              = "${var.server_name}-nsg"
  location                          = var.rg_location
  resource_group_name               = azurerm_resource_group.test_rg.name
}

resource "azurerm_network_security_rule" "test_nsg_rule_rdp"{
  name = "RDP Inbound"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_port_range = "3389"
  destination_address_prefix = "*"
  resource_group_name   = azurerm_resource_group.test_rg.name
  network_security_group_name = azurerm_network_security_group.test_nsg.name
}

resource "azurerm_network_interface_security_group_association" "test_nsg_association"{
  network_security_group_id = azurerm_network_security_group.test_nsg.id
  network_interface_id = azurerm_network_interface.test_nic.id
}