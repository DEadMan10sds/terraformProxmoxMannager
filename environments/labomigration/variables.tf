variable "proxmox_endpoint" {
  description = "URL de la API de Proxmox"
  type        = string
}

variable "proxmox_api_token" {
  description = "API token de Proxmox en formato user@realm!tokenid=secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Nodo de Proxmox donde se crearán los recursos"
  type        = string
  default     = "server1"
}

variable "lxc_root_password" {
  description = "Contraseña de root para LXCs"
  type        = string
  sensitive   = true
}