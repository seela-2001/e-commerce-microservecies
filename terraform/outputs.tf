output "instance_public_ip" {
    value = aws_instance.app_server.public_ip
}

output "ssh_private_key" {
    value = local_file.private_key.filename
}

resource "local_file" "ansible_inventory" {
    content  = "[webservers]\n${aws_instance.app_server.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${local_file.private_key.filename} ansible_become=true"
    filename = "./hosts.ini"
}

output "server_user" {
  value = "ubuntu"
}