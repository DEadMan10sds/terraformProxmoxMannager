data "proxmox_virtual_environment_nodes" "available" {}

output "proxmox_nodes" {
  value = data.proxmox_virtual_environment_nodes.available.names
}
/*
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
}

output "reverse_proxy_ip" {
  value = module.reverse_proxy.ip_address
}
*/