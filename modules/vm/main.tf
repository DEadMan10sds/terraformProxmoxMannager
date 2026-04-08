resource "proxmox_virtual_environment_vm" "this" {
  node_name = var.node_name
  vm_id     = var.vm_id
  name      = var.hostname
  tags      = var.tags
  started   = true

  description = "Managed by Terraform"

  # Boot order opcional
  boot_order = var.boot_order != [] ? var.boot_order : null

  agent {
    enabled = true
  }

  cpu {
    cores   = var.cores
    sockets = var.sockets
    type    = "x86-64-v2-AES"
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
    file_id = var.image_id != "" && var.create_from_image ? var.image_id : null
  }

  network_device {
    bridge   = var.bridge
    vlan_id  = var.vlan_tag
    firewall = false
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ip_address != "" ? var.ip_address : null
        gateway = var.gateway != "" ? var.gateway : null
      }
    }

    user_account {
      username = var.ssh_user
      password = var.password != null ? var.password : null
      keys     = var.ssh_public_keys != "" ? [trimspace(var.ssh_public_keys)] : []
    }

    user_data = <<-EOF
      #cloud-config
      packages:
        - qemu-guest-agent
      runcmd:
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
    EOF
  }

  operating_system {
    type = "l26"
  }
}