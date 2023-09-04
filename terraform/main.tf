#configuring a rg
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# configuring a vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-terraform-prod-westeu"
  address_space       = ["10.1.0.0/22"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#configuring 2 subnets
resource "azurerm_subnet" "snet-web" {
  address_prefixes     = ["10.1.0.0/24"]
  name                 = "snet-web-westeu"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}
resource "azurerm_subnet" "snet-db" {
  address_prefixes     = ["10.1.1.0/24"]
  name                 = "snet-db-westeu"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

#configuring a web nsg
resource "azurerm_network_security_group" "nsg-web" {
  location            = azurerm_resource_group.rg.location
  name                = "nsg-terraform-prod-web"
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "opentowebonport${var.web_app_port}"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = var.web_app_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allowsshtoprivateip"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = var.source_ip_address
    destination_address_prefix = "*"
  }
}

#configuring a db nsg
resource "azurerm_network_security_group" "nsg-db" {
  location            = azurerm_resource_group.rg.location
  name                = "nsg-terraform-prod-db"
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "port5432opentowebsnet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = 5432
    source_address_prefix      = "10.1.0.0/24"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allowsshtoprivateip"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = var.source_ip_address
    destination_address_prefix = "*"
  }
}

#associating web snet to web-nsg
resource "azurerm_subnet_network_security_group_association" "nsg-web-ass" {
  subnet_id                 = azurerm_subnet.snet-web.id
  network_security_group_id = azurerm_network_security_group.nsg-web.id
}

#associating db snet to db-nsg
resource "azurerm_subnet_network_security_group_association" "nsg-db-ass" {
  subnet_id                 = azurerm_subnet.snet-db.id
  network_security_group_id = azurerm_network_security_group.nsg-db.id
}

#creating public ip for web-vm
resource "azurerm_public_ip" "pip-web" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "pip-vmweb-prod-westeu"
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Basic"
}

#creating public ip for db-vm
resource "azurerm_public_ip" "pip-db" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "pip-vmdb-prod-westeu"
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Basic"
}

#configuring nic for web-vm
resource "azurerm_network_interface" "nic-web" {
  name                = "nic-webvm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     =  azurerm_subnet.snet-web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip-web.id
  }
}

#configuring nic for db-vm
resource "azurerm_network_interface" "nic-db" {
  name                = "nic-dbvm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name



  ip_configuration {
    name                          = "internal"
    subnet_id                     =  azurerm_subnet.snet-db.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.1.1.4"
    public_ip_address_id = azurerm_public_ip.pip-db.id
  }
}

#configure ssh key
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "ssh_pem" {
  filename = "${path.module}\\web_db_key.pem"
  content = tls_private_key.vm_ssh.private_key_pem
}

#configuring vm for web app
resource "azurerm_linux_virtual_machine" "vm-web" {
  name                            = "vm-web"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1ls"
  admin_username                  = var.admin_user
#  admin_password                  = var.admin_password
#  disable_password_authentication = false
  network_interface_ids           = [
    azurerm_network_interface.nic-web.id,
  ]
  admin_ssh_key {
    public_key = tls_private_key.vm_ssh.public_key_openssh
    username   = var.admin_user
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }
  depends_on = [
    azurerm_linux_virtual_machine.vm-db
  ]
}

#configuring vm for db
resource "azurerm_linux_virtual_machine" "vm-db" {
  name                            = "vm-db"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1ls"
  admin_username                  = var.admin_user
  #admin_password                  = var.admin_password
  #disable_password_authentication = false
  network_interface_ids           = [
    azurerm_network_interface.nic-db.id,
  ]
  admin_ssh_key {
    public_key = tls_private_key.vm_ssh.public_key_openssh
    username   = var.admin_user
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }
}

#creating db extension
resource "azurerm_virtual_machine_extension" "db_ext" {
  name                 = "install_flask"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-db.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
 {
  "commandToExecute": "git clone https://github.com/Milk18/terraform_project.git && sudo sh final_terraform/shell_scripts/db_script.sh"
}
SETTINGS
  depends_on = [
  azurerm_linux_virtual_machine.vm-db
  ]
}

#creating web extension
resource "azurerm_virtual_machine_extension" "web_ext" {
  name                 = "install_flask"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-web.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
 {
  "commandToExecute": "git clone https://github.com/Milk18/terraform_project.git && sudo sh final_terraform/shell_scripts/web_script.sh"
}
SETTINGS
  depends_on = [
  azurerm_linux_virtual_machine.vm-db,
    azurerm_virtual_machine_extension.db_ext,
    azurerm_linux_virtual_machine.vm-web
  ]
}

