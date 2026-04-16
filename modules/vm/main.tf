resource "proxmox_virtual_environment_vm" "this" {
  node_name = var.node_name
  vm_id     = var.vm_id
  name      = var.hostname
  tags      = var.tags
  started   = true

  description = "Managed by Terraform"

  boot_order = var.boot_order != [] ? var.boot_order : null

  agent {
    enabled = true
  }

  clone {
    vm_id = var.template_id
  }

  cpu {
    cores   = var.cores
    sockets = var.sockets
    type    = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = var.disk_interface
    size         = var.disk_size
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge   = var.bridge
    vlan_id  = var.vlan_tag
    firewall = false
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      username = var.ssh_user
      password = var.password
       keys     = [file("~/.ssh/id_ed25519.pub")]
    }
  }

  operating_system {
    type = "l26"
  }
}