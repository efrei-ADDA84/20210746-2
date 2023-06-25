#provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.62.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "765266c6-9a23-4638-af32-dd1e32613047"
  features {}
}


#network

data "azurerm_virtual_network" "network-paul" {
  name                = var.network
  resource_group_name = var.azure_resource_group
}

data "azurerm_subnet" "tp4" {
  name                 = "internal"
  resource_group_name  = var.azure_resource_group
  virtual_network_name = data.azurerm_virtual_network.network-paul.name
}

resource "azurerm_network_interface" "tp4" {
  name                = "net_interface_20210746"
  location            = var.region
  resource_group_name = var.azure_resource_group
  ip_configuration {
    name                          = "config"
    subnet_id                     = data.azurerm_subnet.tp4.id
    private_ip_address_allocation = "Dynamic"
  }
}



#vm
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "tp4" {
  name                = "devops-20210746"
  location            = var.region
  resource_group_name = var.azure_resource_group
  size                = "Standard_D2s_v3"
  admin_username      = "devops"
  network_interface_ids = [
    azurerm_network_interface.tp4.id,
  ]

  admin_ssh_key {
    username   = "devops"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    name                 = "osdisk_20210746"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}