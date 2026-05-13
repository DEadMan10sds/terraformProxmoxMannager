variable "proxmox_endpoint" {
  type    = string
}

variable "proxmox_username" {
  type      = string
  sensitive = true
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "vm_template" {
  type    = string
  default = "ubuntu-2404-template"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}