
provider "azurerm" {
  features {}

  subscription_id = "96a83b50-c77d-40ae-b8b9-4930e9787e23"
}

resource "azurerm_resource_group" "devops_rg" {
  name     = "devops-rg"
  location = "South India"
}

resource "azurerm_virtual_network" "devops_net" {
  name                = "devops-network"
  resource_group_name = azurerm_resource_group.devops_rg.name
  location            = azurerm_resource_group.devops_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "devops_app_sub" {
  name                 = "devops-subnet"
  resource_group_name  = azurerm_resource_group.devops_rg.name
  virtual_network_name = azurerm_virtual_network.devops_net.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "devops_pub" {
  name                = "devops-pub-ip"
  resource_group_name = azurerm_resource_group.devops_rg.name
  location            = azurerm_resource_group.devops_rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "devops_ni" {
  name                = "devops-ni"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devops_app_sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops_pub.id
  }
}

resource "azurerm_linux_virtual_machine" "devops_app_vm" {
  name                = "devops-app-vm"
  resource_group_name = azurerm_resource_group.devops_rg.name
  location            = azurerm_resource_group.devops_rg.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.devops_ni.id,
  ]

#  admin_ssh_key {
#    username   = "azureuser"
#    public_key = file("./devops.pub")
#  }

#This method is not recommended. Get passwords from keyvaults
  admin_password   = "$m4RtCar3!969"
  disable_password_authentication = "false"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-3-free"
    sku       = "centos-8-3-free"
    version   = "latest"
  }

  plan {
    publisher = "cognosys"
    name      = "centos-8-3-free"
    product   = "centos-8-3-free"
  }
}

resource "azurerm_network_security_group" "devops_nsg" {
  name                = "devops-nsg"
  location            = azurerm_resource_group.devops_rg.location
  resource_group_name = azurerm_resource_group.devops_rg.name

  security_rule {                   
    name                       = "HTTP"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }                                 
                                    
    security_rule {                 
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }   
}

resource "azurerm_subnet_network_security_group_association" "devops-asc" {
  subnet_id                 = azurerm_subnet.devops_app_sub.id
  network_security_group_id = azurerm_network_security_group.devops_nsg.id
}
