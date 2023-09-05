output "web_vm_ip" {
  value = azurerm_public_ip.pip-web.ip_address
}

output "db_vm_ip" {
  value = azurerm_public_ip.pip-db.ip_address
}

output "rg_location" {
  value = var.location
}
output "web_ssh" {
  value = tls_private_key.vm_ssh.private_key_pem
  sensitive = true
}
output "web_port" {
  value = var.web_app_port
}