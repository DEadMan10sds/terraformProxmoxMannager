########################################
# DATA
########################################

data "proxmox_virtual_environment_nodes" "available" {}

output "proxmox_nodes" {
  value = data.proxmox_virtual_environment_nodes.available.names
}

########################################
# CLOUD IMAGE UBUNTU (SOLO PARA VMs NUEVAS)
########################################

resource "proxmox_download_file" "debian12" {
  node_name    = var.proxmox_node
  content_type = "iso"
  datastore_id = "local"
  url          = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  file_name    = "debian-12-generic-amd64.img"
  overwrite    = false
}

########################################
# LXC (NO CAMBIAR TEMPLATE)
########################################

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

  ip_address = "172.16.120.10/24"
  gateway    = "172.16.120.1"

  vlan_tag = 120
  bridge   = "vmbr0"

  root_password   = var.lxc_root_password
  ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "nginx", "reverse-proxy"]
}

########################################
# VMs EXISTENTES (NO TOCAR DISCO)
########################################

module "piggybank" {
  source = "../../modules/vm"

  node_name      = "server1"
  vm_id          = 101
  hostname       = "PiggyBank"
  cores          = 4
  sockets        = 2
  memory         = 8192
  disk_size      = 80
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  template_id = 9999
  ip_address = "172.16.120.11/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"

  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]

  password = var.vm_passwords["PiggyBank"]

}

module "beeprovi" {
  source = "../../modules/vm"

  node_name      = "server1"
  vm_id          = 102
  hostname       = "Beeprovi"
  cores          = 4
  sockets        = 2
  memory         = 4096
  disk_size      = 128
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  ip_address = "172.16.120.12/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"
  template_id = 9999
  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]
  
  password = var.vm_passwords["Beeprovi"]
}

module "pruebas" {
  source         = "../../modules/vm"
  node_name      = var.proxmox_node
  vm_id          = 103
  hostname       = "Pruebas"

  cores          = 4
  sockets        = 2
  memory         = 4096

  disk_size      = 80
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  template_id = 9999
  ip_address = "172.16.120.13/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"

  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")
  password        = var.vm_passwords["Pruebas"]

  tags = ["terraform", "vm", "pruebas"]
}

module "pruebas2" {
  source         = "../../modules/vm"
  node_name      = var.proxmox_node
  vm_id          = 104
  hostname       = "Pruebas2"

  cores          = 4
  sockets        = 2
  memory         = 4096

  disk_size      = 80
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  template_id = 9998
  ip_address = "172.16.120.14/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"

  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")
  password        = var.vm_passwords["Pruebas"]

  tags = ["terraform", "vm", "pruebas"]
}

########################################
# OUTPUTS
########################################

output "reverse_proxy_ip" { value = module.reverse_proxy.ip_address }
output "piggybank_ip"     { value = module.piggybank.ip_address }
output "beeprovi_ip"      { value = module.beeprovi.ip_address }
output "pruebas_ip"       { value = module.pruebas.ip_address }

########################################
# LOCALS (ANSIBLE)
########################################

locals {
  vms = [module.piggybank, module.beeprovi, module.pruebas]
  lxc = [module.reverse_proxy]

  qemu_hosts = [
    for vm in local.vms : {
      name = vm.hostname
      ip   = split("/", vm.ip_address)[0]
      user = vm.ssh_user
    }
  ]

  lxc_hosts = [
    for c in local.lxc : {
      name = c.hostname
      ip   = split("/", c.ip_address)[0]
      user = "root"
    }
  ]

  vhosts_hash   = sha1(jsonencode(var.vhosts))
  qemu_hash     = sha1(jsonencode(local.qemu_hosts))
  lxc_hash      = sha1(jsonencode(local.lxc_hosts))
  qemu_ips_hash = sha1(jsonencode([for vm in local.qemu_hosts : vm.ip]))
}

########################################
# ANSIBLE
########################################

resource "local_file" "ansible_vars" {
  filename = "/home/tfuser/terraformProxmoxMannager/ansible/vars/generated.yml"

  content = templatefile("${path.module}/generated.yml.tpl", {
    vhosts     = var.vhosts
    qemu_hosts = local.qemu_hosts
    lxc_hosts  = local.lxc_hosts
  })
}

########################################
# PIPELINE
########################################

resource "null_resource" "vm_pipeline" {
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=/home/tfuser/terraformProxmoxMannager/ansible/ansible.cfg ansible-playbook -i /home/tfuser/terraformProxmoxMannager/ansible/inventory/hosts.yml /home/tfuser/terraformProxmoxMannager/ansible/playbooks/qemu_agent.yml"
  }

  triggers   = { qemu = local.qemu_hash }
  depends_on = [ local_file.ansible_vars]
}

resource "null_resource" "lxc_pipeline" {
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=/home/tfuser/terraformProxmoxMannager/ansible/ansible.cfg ansible-playbook -i /home/tfuser/terraformProxmoxMannager/ansible/inventory/hosts.yml /home/tfuser/terraformProxmoxMannager/ansible/playbooks/qemu_agent.yml"
  }

  triggers   = { lxc = local.lxc_hash }
  depends_on = [module.reverse_proxy, local_file.ansible_vars]
}

resource "null_resource" "nginx_pipeline" {
  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=/home/tfuser/terraformProxmoxMannager/ansible/ansible.cfg ansible-playbook -i /home/tfuser/terraformProxmoxMannager/ansible/inventory/hosts.yml /home/tfuser/terraformProxmoxMannager/ansible/playbooks/reverse-proxy.yml"
  }

  triggers   = { vhosts = local.vhosts_hash }
  depends_on = [module.reverse_proxy, local_file.ansible_vars]
}