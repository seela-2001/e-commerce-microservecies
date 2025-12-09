output "instance_public_ip" {
    value = aws_instance.app_server.public_ip
}

output "ssh_private_key" {
    value = local_file.private_key.filename
}
