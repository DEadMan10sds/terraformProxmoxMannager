variable "node_name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "hostname" {
  type = string
}

variable "cores" {
  type    = number
  default = 2
}

variable "boot_order" {
  description = "Lista de dispositivos de arranque"
  type = list(string)
  default = [  ]
}

variable "sockets" { 
  description = "Número de sockets de CPU para VM"
  type = number
  default = 1
}

variable "memory" {
  type    = number
  default = 2048
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "ssh_user" {
  type = string
  description = "User for ssh connection"
}

variable "password" {
  description = "Password para usuario de VM"
  type = string
  sensitive = true
  default = null
}

variable "disk_interface" {
  type = string
  description = "Disk interface"
  default = "scsi"
}

variable "datastore_id" {
  type    = string
  default = "VMStorage"
}

variable "image_id" {
  description = "ID de la imagen cloud-init en Proxmox, ej: local:iso/debian-12-generic-amd64.img"
  type        = string
  default     = null
}

variable "ip_address" {
  type = string
}

variable "gateway" {
  type = string
}

variable "vlan_tag" {
  type    = number
  default = null
}

variable "bridge" {
  type    = string
  default = "vmbr120"
}

variable "ssh_public_keys" {
  type    = string
  default = ""
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "ignore_disk_changes" {
  type    = bool
  default = false
}