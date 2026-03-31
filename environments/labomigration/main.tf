data "proxmox_virtual_environment_nodes" "available" {}

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
  vlan_tag         = 120
  bridge           = "vmbr0"
  tags             = ["terraform", "test"]
}

output "test_lxc_ip" {
  value = module.test_lxc.ip_address
}