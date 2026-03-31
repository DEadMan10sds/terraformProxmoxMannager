resource "proxmox_virtual_environment_container" "this" {
  node_name    = var.node_name
  vm_id        = var.vm_id
  description  = "Managed by Terraform"
  tags         = var.tags
  unprivileged = var.unprivileged
  started      = true

  startup {
    order    = 1
    up_delay = 10
  }

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      keys = var.ssh_public_keys != "" ? [var.ssh_public_keys] : []
    }
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  network_interface {
    name     = "eth0"
    bridge   = var.bridge
    vlan_id  = var.vlan_tag
    firewall = false
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = "debian"
  }

  features {
    nesting = true
  }
}