resource "aws_eip" "app_server_ip" {
  count  = length(var.availability_zones)
  domain = "vpc" 
  tags = {
    Name = "${var.project_id}-app-eip-${count.index}"
  }
}

resource "aws_eip_association" "app_server_eip_assoc" {
  count         = length(aws_instance.app_server)
  instance_id   = aws_instance.app_server[count.index].id
  allocation_id = aws_eip.app_server_ip[count.index].id
}