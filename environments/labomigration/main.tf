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

resource "proxmox_virtual_environment_download_file" "debian12" {
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

module "PiggybankDev" {
  source = "../../modules/vm"

  node_name      = "server1"
  cpu_type = "x86-64-v3"
  vm_id          = 101
  hostname       = "PiggybankDev"
  cores          = 4
  sockets        = 2
  memory         = 8192
  disk_size      = 880
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

  password = var.vm_passwords["PiggybankDev"]

}

module "BeeproviTest" {
  source = "../../modules/vm"

  node_name      = "server1"
  vm_id          = 103
  cpu_type = "x86-64-v3"
  hostname       = "BeeproviTest"
  cores          = 4
  sockets        = 2
  memory         = 4096
  disk_size      = 150
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  ip_address = "172.16.120.13/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"
  template_id = 9999
  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]
  
  password = var.vm_passwords["Beeprovi"]
}

module "BeeproviDev" {
  source = "../../modules/vm"

  node_name      = "server1"
  vm_id          = 102
  hostname       = "BeeproviDev"
  cpu_type = "host"
  cores          = 4
  sockets        = 2
  memory         = 8196
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
  
  password = var.vm_passwords["BeeproviDev"]
}

module "Beeprovi" {
  source = "../../modules/vm"

  node_name      = "server1"
  vm_id          = 110
  hostname       = "Beeprovi"
  cpu_type = "x86-64-v3"
  cores          = 4
  sockets        = 2
  memory         = 4098
  disk_size      = 150
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  ip_address = "172.16.120.110/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"
  template_id = 9999
  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]
  
  password = var.vm_passwords["Beeprovi"]
}

module "Piggybank" {
  source = "../../modules/vm"

  node_name      = "server2"
  vm_id          = 111
  hostname       = "Piggybank"
  cores          = 4
  sockets        = 2
  memory         = 8192
  disk_size      = 80
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  template_id = 9999
  ip_address = "172.16.120.111/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"

  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]

  password = var.vm_passwords["Piggybank"]

}

module "Bitracker" {
  source = "../../modules/vm"

  node_name      = "server2"
  vm_id          = 112
  hostname       = "Bitracker"
  cores          = 4
  sockets        = 2
  memory         = 8192
  disk_size      = 60
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  template_id = 9999
  ip_address = "172.16.120.112/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"

  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]

  password = var.vm_passwords["Bitracker"]
}


module "Wiki" {
  source = "../../modules/vm"

  node_name      = "server2"
  vm_id          = 113
  hostname       = "Wiki"
  cores          = 4
  sockets        = 2
  memory         = 8192
  disk_size      = 150
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  template_id = 9999
  ip_address = "172.16.120.113/24"
  gateway    = "172.16.120.1"
  bridge     = "vmbr120"

  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]

  password = var.vm_passwords["Wiki"]

}

module "ProxmoxBackupServerSecundary" {
  source = "../../modules/vm"

  node_name      = "server1"
  vm_id          = 107
  hostname       = "ProxBackupSrvr"
  cores          = 4
  sockets        = 1
  memory         = 16384
  disk_size      = 80
  datastore_id   = "VMStorage"
  disk_interface = "scsi0"
  boot_order     = ["scsi0"]
  ip_address = "172.16.140.11/24"
  gateway    = "172.16.140.1"
  bridge     = "vmbr140"
  template_id = 9997
  ssh_user        = "sysadmin"
  #ssh_public_keys = file("~/.ssh/id_ed25519.pub")

  tags = ["terraform", "vm", "app"]
  
  password = var.vm_passwords["PBSS"]
}


########################################
# OUTPUTS
########################################

output "reverse_proxy_ip" { value = module.reverse_proxy.ip_address }
output "Piggybank_ip"     { value = module.Piggybank.ip_address }
output "PiggybankDev_ip"     { value = module.PiggybankDev.ip_address }
output "Beeprovi_ip"      { value = module.Beeprovi.ip_address }
output "BeeproviDev_ip"      { value = module.BeeproviDev.ip_address }
output "BeeproviTest_ip"      { value = module.BeeproviTest.ip_address }
output "Wiki_ip"      { value = module.Wiki.ip_address }
output "Bitracker_ip"      { value = module.Bitracker }

########################################
# LOCALS (ANSIBLE)
########################################

locals {
  vms = [module.Piggybank, module.PiggybankDev, module.Beeprovi, module.BeeproviDev,  module.Wiki, module.Bitracker, module.BeeproviTest]
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