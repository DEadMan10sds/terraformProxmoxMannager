variable "node_name" {
  description = "Nodo de Proxmox donde se creará el LXC"
  type        = string
}

variable "vm_id" {
  description = "ID del contenedor"
  type        = number
}

variable "root_password" {
  description = "Contraseña de root del LXC"
  type        = string
  sensitive   = true
  default     = ""
}

variable "hostname" {
  description = "Hostname del contenedor"
  type        = string
}

variable "cores" {
  description = "Número de cores"
  type        = number
  default     = 1
}

variable "memory" {
  description = "RAM en MB"
  type        = number
  default     = 512
}

variable "disk_size" {
  description = "Tamaño del disco en GB"
  type        = number
  default     = 8
}

variable "datastore_id" {
  description = "Storage donde se guarda el disco del LXC"
  type        = string
  default     = "local-lvm"
}

variable "template_file_id" {
  description = "Template del contenedor, ej: local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
  type        = string
}

variable "ip_address" {
  description = "IP con prefijo, ej: 172.16.120.50/24"
  type        = string
}

variable "gateway" {
  description = "Gateway de la red"
  type        = string
}

variable "vlan_tag" {
  description = "VLAN tag de la interfaz de red"
  type        = number
  default     = null
}

variable "bridge" {
  description = "Bridge de red en Proxmox"
  type        = string
  default     = "vmbr120"
}

variable "unprivileged" {
  description = "Correr como contenedor sin privilegios"
  type        = bool
  default     = true
}

variable "start_on_boot" {
  description = "Iniciar automáticamente con el nodo"
  type        = bool
  default     = true
}

variable "ssh_public_keys" {
  description = "Claves SSH públicas para acceso al contenedor"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags del contenedor"
  type        = list(string)
  default     = []
}