data "proxmox_virtual_environment_nodes" "available" {}

output "proxmox_nodes" {
  value = data.proxmox_virtual_environment_nodes.available.names
}

module "reverse_proxy" {
  source = "../../modules/lxc"

  node_name        = var.proxmox_node
  vm_id            = 100
  hostname         = "reverse-proxy"
  cores            = 2
  memory           = 512
  disk_size        = 8
  datastore_id     = "local-lvm"
  template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
  ip_address       = "172.16.120.10/24"
  gateway          = "172.16.120.1"
  vlan_tag         = 120
  bridge           = "vmbr0"
  root_password    = var.lxc_root_password
  tags             = ["terraform", "nginx", "reverse-proxy"]
  ssh_public_keys = file("~/.ssh/id_ed25519.pub")
}

output "reverse_proxy_ip" {
  value = module.reverse_proxy.ip_address
}

module "piggybank" {
  source = "../../modules/vm"
  node_name        = "server1"
  vm_id            = 102
  hostname         = "PiggyBank"
  cores            = 2
  sockets          = 1
  memory           = 4096
  disk_size        = 80
  datastore_id     = "VMStorage"
  disk_interface   = "scsi0"
  boot_order       = [ "scsi0" ]
  ip_address       = "172.16.120.11/24"
  gateway          = "172.16.120.1"
  bridge           = "vmbr120"
  tags             = ["terraform", "vm", "app"]
  ssh_user         = "sysadmin"
  ssh_public_keys  = file("~/.ssh/id_ed25519.pub")
}

output "piggybank_ip" {
  value = module.piggybank.ip_address
}

module "beeprovi" {
  source = "../../modules/vm"
  node_name        = "server1"
  vm_id            = 101
  hostname         = "Beeprovi"
  cores            = 4
  sockets          = 2
  memory           = 4096
  disk_size        = 128
  datastore_id     = "VMStorage"
  disk_interface   = "scsi0"
  boot_order       = [ "scsi0" ]
  ip_address       = "172.16.120.12/24"
  gateway          = "172.16.120.1"
  bridge           = "vmbr120"
  tags             = ["terraform", "vm", "app"]
  ssh_user         = "sysadmin"
  ssh_public_keys  = file("~/.ssh/id_ed25519.pub")
}

output "beeprovi_ip" {
  value = module.piggybank.ip_address
}