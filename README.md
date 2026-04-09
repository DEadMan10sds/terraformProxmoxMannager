# Guide to manage ansible & terraform

## Terraform

> Please generate ssh key for a better use

Enter to environment
Run:

1. terraform plan
2. terraform apply

**Lookup for the user with the access to terraform repo (tfuser)**

### Terraform migration of existing VM's

To migrate an existing vm that was created without terraform, you must define the config file (as any other vm) with the correct VM data.

#### Getting vm data

Inside a cluster node:
`qm config vm_id`

With that config we can fill the information as in the example:
`module "vmname" {
  source = "../../modules/vm"
  node_name        = "server1"
  vm_id            = vmID
  hostname         = "VmHost"
  cores            = 4
  sockets          = 2
  memory           = 4096
  disk_size        = 128
  datastore_id     = "VMStorage"
  disk_interface   = "scsi0"
  boot_order       = [ "scsi0" ]
  ip_address       = "172.16.120.12/24"
  gateway          = "172.16.120.1"
  bridge           = "vmbr120"
  tags             = ["terraform", "vm", "app"]
  ssh_public_keys  = file("~/.ssh/id_ed25519.pub")
}`

Then you must run the command to adopt the vm:
`terraform import module.vm_host_name.proxmox_virtual_environment_vm.this proxmox_node/vm_id`

From here you can run to apply the changes:
1.- `terraform plan`
2.- `terraform apply`

## Trigger ansible

Inside ansible folder run:

`ansible-playbook -i inventory/hosts.yml playbooks/reverse-proxy.yml` -> If ssh is configured

`ansible-playbook -i inventory/hosts.yml playbooks/reverse-proxy.yml -e "lxc_root_password=tu_password"` -> For using password

### Helper if ansible is using password

`export ANSIBLE_HOST_KEY_CHECKING=False`

### Edit secrets.yml for vHosts

To handle each vhost you must edit secrets.ym inside /vars, ansible will loop all vhosts defined and install certificates

## Allow ssh on LXC

If a container doesn't allows ssh, we must edit the sshd_config file

1. Access to lxc via proxmox:
   `pct enter <id>`
2. Access file: `nano /etc/ssh/sshd_config`
3. Edit the lines: <br>
   `PermitRootLogin yes` <br>
   `PasswordAuthentication yes`
4. Restart ssh: `systemctl restart ssh`

## Create template for VM

wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
qm create 9000 --name ubuntu-22-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 jammy-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci
qm set 9000 --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --ciuser ubuntu
qm set 9000 --cipassword ubuntu
qm set 9000 --ipconfig0 ip=dhcp
qm set 9000 --agent enabled=1

### Verify disk size to avoid update errors -> Proxmox webui

qm start 9000
qm terminal 9000

sudo apt update
sudo apt install -y qemu-guest-agent cloud-init
sudo systemctl start qemu-guest-agent
sudo systemctl enable --now qemu-guest-agent
sudo systemctl disable systemd-networkd-wait-online
sudo nano /etc/ssh/sshd_config

---

PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes

---

ls /etc/ssh/sshd_config.d/
sudo nano /etc/ssh/sshd_config.d/\*.conf

---

## PasswordAuthentication no

sudo systemctl restart ssh
sudo cloud-init clean
sudo shutdown now

qm set 9000 --delete serial0
qm set 9000 --delete vga
qm set 9000 --delete ciuser
qm set 9000 --delete cipassword
qm template 9000
