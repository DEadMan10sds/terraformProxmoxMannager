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
