# to override default value specify -var 'varname' = "new value" while applying
# you can use predefined os env while exporting var starting wit TF_VAR_"varname" and use {} to call it
variable "resource_group_name" {
  type = string
  default = "rg-terraform-prod-westeu"
}

variable "location" {
  type = string
  default= "westeurope"
}
variable "db_password" {
  description = "db password"
  type = string
}
variable "db_private_ip" {
  description = "db private ip"
  type = string
  default = "10.1.1.4"
}

variable "web_app_port" {
  description = "open to web app exported port"
  type = number
  default = 8080
}

variable "admin_user" {
  description = "vm's username"
  type = string
}

variable "admin_password" {
  description = "vm's password (currently not in use due to ssh config)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.admin_password)>6
    error_message = "password too short"
  }
}

variable "source_ip_address" {
  type = string
  default = "*"
  # "46.117.157.196"
}

variable "vm_image_info" {
  description = "info for creating our vm, both db and web are the same size and image"
  type = object({
    size      = string
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    size      = "Standard_B1ls"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }
}

variable "disk_mount" {
  description = "list of commands to mounting disk to the vm"
  type = list(string)
  default = [
    "sudo mkfs -t ext4 /dev/sdc",
    "sudo mkdir /data1",
    "sudo mount /dev/sdc /data1"
    ]
}

variable "git_repo" {
  description = "git repo that is used by the extension"
  type = string
  default = "https://github.com/Milk18/terraform_project.git"
}

variable "extension_git_path" {
  description = "vm path to activate bash scripts"
  type = string
  default = "var/lib/waagent/custom-script/download/0/terraform_project/shell_scripts"
}