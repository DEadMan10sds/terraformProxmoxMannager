terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.46"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
}

# ─── Control Plane ───────────────────────────────────────────────────────────

module "k8s_cp" {
  source      = "../../modules/vm"
  vmid        = 200
  name        = "k8s-cp-01"
  target_node = "server1"
  cores       = 4
  sockets     = 1
  memory      = 8192
  disk_size   = 51200       # 50 GB en MB
  storage     = "k8s-thin-store"
  vlan_tag    = 120
  ip          = "172.16.120.100/24"
  gateway     = "172.16.120.1"
  nameserver  = "172.16.120.1"
  template    = var.vm_template
  ssh_keys    = trimspace(file(var.ssh_public_key_path))
  tags        = ["k8s", "control-plane"]

  startup = {
    order      = 1
    up_delay   = 30
    down_delay = 10
  }
}

# ─── Worker 01 ───────────────────────────────────────────────────────────────

# module "k8s_worker_01" {
#   source      = "../../../modules/vm"
#   vmid        = 201
#   name        = "k8s-worker-01"
#   target_node = "server1"
#   cores       = 10
#   sockets     = 1
#   memory      = 14336       # 14 GB
#   disk_size   = 102400      # 100 GB
#   storage     = "k8s-thin-store"
#   vlan_tag    = 120
#   ip          = "172.16.120.101/24"
#   gateway     = "172.16.120.1"
#   nameserver  = "172.16.120.1"
#   template    = var.vm_template
#   ssh_keys    = trimspace(file(var.ssh_public_key_path))
#   tags        = ["k8s", "worker"]

#   startup = {
#     order      = 2
#     up_delay   = 60
#     down_delay = 10
#   }

#   depends_on = [module.k8s_cp]
# }

# # ─── Worker 02 ───────────────────────────────────────────────────────────────

# module "k8s_worker_02" {
#   source      = "../../../modules/vm"
#   vmid        = 202
#   name        = "k8s-worker-02"
#   target_node = "server2"
#   cores       = 12
#   sockets     = 1
#   memory      = 20480       # 20 GB
#   disk_size   = 102400      # 100 GB
#   storage     = "k8s-thin-store"
#   vlan_tag    = 120
#   ip          = "172.16.120.102/24"
#   gateway     = "172.16.120.1"
#   nameserver  = "172.16.120.1"
#   template    = var.vm_template
#   ssh_keys    = trimspace(file(var.ssh_public_key_path))
#   tags        = ["k8s", "worker"]

#   startup = {
#     order      = 2
#     up_delay   = 60
#     down_delay = 10
#   }

#   depends_on = [module.k8s_cp]
# }

# # ─── DB VMs ──────────────────────────────────────────────────────────────────

# module "db_vm_01" {
#   source      = "../../../modules/vm"
#   vmid        = 210
#   name        = "db-vm-01"
#   target_node = "server2"
#   cores       = 6
#   sockets     = 1
#   memory      = 6144        # 6 GB
#   disk_size   = 81920       # 80 GB
#   storage     = "VMStorage" # disco local del VRTX, mejor latencia para DBs
#   vlan_tag    = 120
#   ip          = "172.16.120.51/24"
#   gateway     = "172.16.120.1"
#   nameserver  = "172.16.120.1"
#   template    = var.vm_template
#   ssh_keys    = trimspace(file(var.ssh_public_key_path))
#   tags        = ["database", "primary"]
# }

# module "db_vm_02" {
#   source      = "../../../modules/vm"
#   vmid        = 211
#   name        = "db-vm-02"
#   target_node = "server1"
#   cores       = 6
#   sockets     = 1
#   memory      = 4096        # 4 GB
#   disk_size   = 81920       # 80 GB
#   storage     = "VMStorage"
#   vlan_tag    = 120
#   ip          = "172.16.120.52/24"
#   gateway     = "172.16.120.1"
#   nameserver  = "172.16.120.1"
#   template    = var.vm_template
#   ssh_keys    = trimspace(file(var.ssh_public_key_path))
#   tags        = ["database", "standby"]

#   depends_on = [module.db_vm_01]
# }