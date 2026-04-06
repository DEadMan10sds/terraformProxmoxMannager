## Trigger ansible

Inside ansible folder run:
ansible-playbook -i inventory/hosts.yml playbooks/reverse-proxy.yml -e "lxc_root_password=tu_password"

## Terraform

Enter to environment
Run: 1. terraform plan 2. terraform apply
