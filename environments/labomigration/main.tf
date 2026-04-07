########################################
# DATA
########################################

data "proxmox_virtual_environment_nodes" "available" {}

output "proxmox_nodes" {
  value = data.proxmox_virtual_environment_nodes.available.names
}

########################################
# MÓDULOS
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

module "piggybank" {
  source = "../../modules/vm"

  node_name      = "server1"
  vm_id          = 102
  hostname       = "PiggyBank"
  cores          = 2
  sockets        = 1
  memory         = 4096
  disk_size      = 80
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]

  ip_address = "172.16.120.11/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"

  ssh_user        = "sysadmin"
  ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]
}

module "beeprovi" {
  source = "../../modules/vm"

  node_name      = "server1"
  vm_id          = 101
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

  ssh_user        = "sysadmin"
  ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]
}

########################################
# OUTPUTS
########################################

output "reverse_proxy_ip" {
  value = module.reverse_proxy.ip_address
}

output "piggybank_ip" {
  value = module.piggybank.ip_address
}

output "beeprovi_ip" {
  value = module.beeprovi.ip_address
}

########################################
# LOCALS (SOURCE OF TRUTH → ANSIBLE)
########################################

locals {
  vms = [
    module.piggybank,
    module.beeprovi
  ]

  lxc = [
    module.reverse_proxy
  ]

  qemu_hosts = [
    for vm in local.vms : {
      name = vm.hostname
      ip   = vm.ip_address
      user = vm.ssh_user
    }
  ]

  lxc_hosts = [
    for lxc in local.lxc : {
      name = lxc.hostname
      ip   = lxc.ip_address
      user = "root"
    }
  ]

  ########################################
  # HASHES (PIPELINE INTELIGENTE)
  ########################################

  vhosts_hash = sha1(jsonencode(var.vhosts))
  qemu_hash   = sha1(jsonencode(local.qemu_hosts))
  lxc_hash    = sha1(jsonencode(local.lxc_hosts))

  # Solo IPs → detectar hosts nuevos
  qemu_ips_hash = sha1(jsonencode([
    for vm in local.qemu_hosts : vm.ip
  ]))
}

########################################
# GENERAR VARIABLES PARA ANSIBLE
########################################

resource "local_file" "ansible_vars" {
  filename = "${path.root}/../../ansible/vars/generated.yml"

  content = yamlencode({
    vhosts     = var.vhosts
    qemu_hosts = local.qemu_hosts
    lxc_hosts  = local.lxc_hosts
  })
}

########################################
# PIPELINE INTELIGENTE
########################################

# 🔹 Bootstrap SSH (solo nuevas VMs)
resource "null_resource" "bootstrap" {
  provisioner "local-exec" {
    command = "ansible-playbook ../../ansible/playbooks/bootstrap_ssh.yml"
  }

  triggers = {
    ips = local.qemu_ips_hash
  }

  depends_on = [
    module.piggybank,
    module.beeprovi
  ]
}

# 🔹 Configuración VM (qemu agent, etc)
resource "null_resource" "vm_pipeline" {
  provisioner "local-exec" {
    command = "ansible-playbook ../../ansible/playbooks/qemu_agent.yml"
  }

  triggers = {
    qemu = local.qemu_hash
  }

  depends_on = [
    null_resource.bootstrap
  ]
}

# 🔹 Configuración LXC base
resource "null_resource" "lxc_pipeline" {
  provisioner "local-exec" {
    command = "ansible-playbook ../../ansible/playbooks/lxc_base.yml"
  }

  triggers = {
    lxc = local.lxc_hash
  }

  depends_on = [
    module.reverse_proxy
  ]
}

# 🔹 Nginx / Reverse Proxy
resource "null_resource" "nginx_pipeline" {
  provisioner "local-exec" {
    command = "ansible-playbook ../../ansible/playbooks/nginx.yml"
  }

  triggers = {
    vhosts = local.vhosts_hash
  }

  depends_on = [
    module.reverse_proxy
  ]
}