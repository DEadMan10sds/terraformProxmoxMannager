resource "proxmox_virtual_environment_vm" "this" {
  node_name = var.node_name
  vm_id     = var.vm_id
  name      = var.hostname
  tags      = var.tags
  started   = true

  description = "Managed by Terraform"
  boot_order = ["virtio0"]
  
  agent {
    enabled = false  # requiere qemu-guest-agent instalado en la VM
  }

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "virtio"
    size         = var.disk_size
    discard      = "on"
    iothread     = true
    file_id = var.image_id != null ? var.image_id : null
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
      username = "debian"
      keys     = var.ssh_public_keys != "" ? [var.ssh_public_keys] : []
    }
  }

  operating_system {
    type = "l26"  # Linux kernel 2.6+
  }
}