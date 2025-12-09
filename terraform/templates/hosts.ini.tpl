[frontend]
frontend-server ansible_host=${frontend_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[backend]
backend-server ansible_host=${backend_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[database]
db-server ansible_host=${db_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3