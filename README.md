# Guide to manage ansible & terraform

## Terraform

> Please generate ssh key for a better use

Enter to environment
Run:

1. terraform plan
2. terraform apply

**Lookup for the user with the access to terraform repo (tfuser)**

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
2. Access file: `nano /etc/sshd_config`
3. Edit the lines: <br>
   `PermitRootLogin yes` <br>
   `PasswordAuthentication yes`
4. Restart ssh: `systemctl restart ssh`
