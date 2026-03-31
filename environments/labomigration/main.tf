data "proxmox_virtual_environment_nodes" "available" {}

resource "proxmox_virtual_environment_download_file" "debian12" {
  node_name    = var.proxmox_node
  content_type = "iso"
  datastore_id = "local"
  url          = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  file_name    = "debian-12-generic-amd64.img"
  overwrite    = false
}


output "proxmox_nodes" {
  value = data.proxmox_virtual_environment_nodes.available.names
}

module "test_lxc" {
  source = "../../modules/lxc"

  node_name        = var.proxmox_node
  vm_id            = 201
  hostname         = "test-tf"
  cores            = 1
  memory           = 512
  disk_size        = 8
  datastore_id     = "local-lvm"
  template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  ip_address       = "172.16.120.201/24"
  gateway          = "172.16.120.1"
  vlan_tag         = null
  bridge           = "vmbr120"
  tags             = ["terraform", "test"]
}

output "test_lxc_ip" {
  value = module.test_lxc.ip_address
}

module "test_vm" {
  source = "../../modules/vm"

  node_name    = var.proxmox_node
  vm_id        = 301
  hostname     = "test-vm"
  cores        = 2
  memory       = 2048
  disk_size    = 20
  datastore_id = "local-lvm"
  image_id     = proxmox_virtual_environment_download_file.debian12.id  # referencia al recurso
  ip_address   = "172.16.120.202/24"
  gateway      = "172.16.120.1"
  vlan_tag     = null
  bridge       = "vmbr120"
  tags         = ["terraform", "vm", "test"]
}
output "test_vm_ip" {
  value = module.test_vm.ip_address
}