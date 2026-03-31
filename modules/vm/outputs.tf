output "id" {
  value = proxmox_virtual_environment_vm.this.vm_id
}

output "hostname" {
  value = proxmox_virtual_environment_vm.this.name
}

output "ip_address" {
  value = var.ip_address
}