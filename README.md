## Trigger ansible

Inside ansible folder run:
ansible-playbook -i inventory/hosts.yml playbooks/reverse-proxy.yml -e "lxc_root_password=tu_password"
