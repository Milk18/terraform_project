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

variable "web_app_port" {
  description = "open to web app exported port"
  type = number
  default = 8080
}

variable "admin_user" {
  description = "vm's username"
  type = string
#  default = "oriu"
}

variable "admin_password" {
  description = "vm's password"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.admin_password)>6
    error_message = "password too short"
    #  default = "Ori#123"
  }
}

variable "source_ip_address" {
  type = string
  default = "*"
  # "46.117.157.196"
}
