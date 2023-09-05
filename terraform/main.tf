#configuring a rg 'terraform'
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
  address_prefixes     = [var.web_subnet]
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
    source_address_prefix      = azurerm_subnet.snet-web.address_prefixes[0]
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
    private_ip_address = var.db_private_ip
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
  size                            = var.vm_image_info.size
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
    publisher = var.vm_image_info.publisher
    offer     = var.vm_image_info.offer
    sku       = var.vm_image_info.sku
    version   = var.vm_image_info.version
  }
  depends_on = [
    azurerm_linux_virtual_machine.vm-db
  ]
}

#configuring vm for db
resource "azurerm_linux_virtual_machine" "vm-db" {
  name                  = "vm-db"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_image_info.size
  admin_username        = var.admin_user
  #admin_password                  = var.admin_password
  #disable_password_authentication = false
  network_interface_ids = [
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
    publisher = var.vm_image_info.publisher
    offer     = var.vm_image_info.offer
    sku       = var.vm_image_info.sku
    version   = var.vm_image_info.version
  }
}


#create web vm managed disk
resource "azurerm_managed_disk" "web-disk" {
  name                 = "${azurerm_linux_virtual_machine.vm-web.name}-disk1"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}
#attach web disk to web vm
resource "azurerm_virtual_machine_data_disk_attachment" "web_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.web-disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm-web.id
  lun                = "10"
  caching            = "ReadWrite"
  depends_on = [azurerm_linux_virtual_machine.vm-web, azurerm_managed_disk.web-disk]
}
#web provision to mount disk
resource "null_resource" "web_vm_prov" {
  connection {
    type = "ssh"
    user = var.admin_user
    private_key = tls_private_key.vm_ssh.private_key_pem
    host = azurerm_linux_virtual_machine.vm-web.public_ip_address
  }
  provisioner "remote-exec" {
    inline=[
      "sudo mkfs -t ext4 /dev/sdc",
      "sudo mkdir /data1",
      "sudo mount /dev/sdc /data1"
    ]
  }
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.web_disk_attach
  ]
  triggers = {
    always_run = timestamp()
  }
}

#create db vm managed disk
resource "azurerm_managed_disk" "db-disk" {
  name                 = "${azurerm_linux_virtual_machine.vm-db.name}-disk1"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

#attach db disk to web vm
resource "azurerm_virtual_machine_data_disk_attachment" "db_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.db-disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm-db.id
  lun                = "10"
  caching            = "ReadWrite"
  depends_on = [azurerm_linux_virtual_machine.vm-db, azurerm_managed_disk.db-disk]
}

#db provision to mount disk
resource "null_resource" "db_vm_prov" {
  connection {
    type = "ssh"
    user = var.admin_user
    private_key = tls_private_key.vm_ssh.private_key_pem
    host = azurerm_linux_virtual_machine.vm-db.public_ip_address
  }
  provisioner "remote-exec" {
    inline= [
      "sudo mkfs -t ext4 /dev/sdc",
      "sudo mkdir /data1",
      "sudo mount /dev/sdc /data1"
      ]
  }
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.db_disk_attach
  ]
  triggers = {
    always_run = timestamp()
  }
}

#creating db extension
resource "azurerm_virtual_machine_extension" "db_ext" {
  name                 = "init_postgresql"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-db.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "sudo apt-get update && sudo apt install git -y && git clone ${var.git_repo} && sudo bash /${var.extension_git_path}/db_script.bash '${var.web_app_port}' '${var.db_private_ip}' '${var.admin_user}' '${var.db_password}' '${var.web_subnet}' "
}
SETTINGS
  depends_on = [
    null_resource.db_vm_prov
  ]
}

#creating web extension
resource "azurerm_virtual_machine_extension" "web_ext" {
  name                 = "install_run_flask"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-web.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
 {
  "commandToExecute": "sudo apt-get update && sudo apt install git -y && git clone ${var.git_repo} && sudo bash /${var.extension_git_path}/web_script.bash '${var.web_app_port}' '${var.db_private_ip}' '${var.admin_user}' '${var.db_password}' '${var.web_subnet}' "
}
SETTINGS
  depends_on = [
    azurerm_linux_virtual_machine.vm-web,
    azurerm_virtual_machine_extension.db_ext
  ]
}

