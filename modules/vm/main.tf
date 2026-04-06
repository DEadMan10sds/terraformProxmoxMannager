resource "proxmox_virtual_environment_vm" "this" {
  node_name = var.node_name
  vm_id     = var.vm_id
  name      = var.hostname
  tags      = var.tags
  started   = true

  description = "Managed by Terraform"
  boot_order = ["virtio0"]
  
  agent {
    enabled = true  # requiere qemu-guest-agent instalado en la VM
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
    interface    = "virtio0"
    size         = var.disk_size
    discard      = "on"
    iothread     = true
    dynamic "file_id_block" {
      for_each = var.image_id != null ? [1] : []
        content {
          file_id = var.image_id
        }
    }
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