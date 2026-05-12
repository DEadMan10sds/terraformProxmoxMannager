vhosts:
%{ for v in vhosts ~}
  - name: "${v.name}"
    domain: "${v.domain}"
    backend: "${v.backend}"
%{ if v.client_max_body_size != null ~}
    client_max_body_size: "${v.client_max_body_size}"
%{ endif ~}
%{ endfor ~}
qemu_hosts:
%{ for h in qemu_hosts ~}
  - name: "${h.name}"
    ip: "${h.ip}"
    user: "${h.user}"
%{ endfor ~}
lxc_hosts:
%{ for h in lxc_hosts ~}
  - name: "${h.name}"
    ip: "${h.ip}"
    user: "${h.user}"
%{ endfor ~}