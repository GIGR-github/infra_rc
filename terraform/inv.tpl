[managers]
%{ for node in managers ~}
${node.name} ansible_host=${node.ipv4[0]}
%{ endfor ~}

[workers]
%{ for node in workers ~}
${node.name} ansible_host=${node.ipv4[0]}
%{ endfor ~}

[cluster:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
