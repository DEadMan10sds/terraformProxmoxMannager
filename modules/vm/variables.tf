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

variable "memory" {
  type    = number
  default = 2048
}

variable "disk_size" {
  type    = number
  default = 20
}

variable "datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "image_id" {
  description = "ID de la imagen cloud-init en Proxmox, ej: local:iso/debian-12-generic-amd64.img"
  type        = string
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