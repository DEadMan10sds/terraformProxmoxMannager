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
