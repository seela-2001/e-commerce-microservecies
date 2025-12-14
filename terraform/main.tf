resource "aws_security_group" "app_sg" {
    name        = "${var.project_id}-sg"
    description = "Allow SSH, Frontend (${var.frontend_port}), Backend (${var.backend_port})"
    vpc_id      = aws_vpc.main.id # References VPC defined in vpc.tf
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Frontend Port
    ingress {
        from_port   = var.frontend_port
        to_port     = var.frontend_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Backend Port
    ingress {
        from_port   = var.backend_port
        to_port     = var.backend_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_id}-sg"
    }
}

resource "tls_private_key" "pk" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
    key_name   = "${var.project_id}-key-2"
    public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "private_key" {
    filename        = "${path.module}/${var.project_id}-key.pem"
    content         = tls_private_key.pk.private_key_pem
    file_permission = "0400" 
}

resource "aws_instance" "app_server" {
    ami                    = var.ami_id
    instance_type          = var.ec2_type
    subnet_id              = aws_subnet.public[count.index].id
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    key_name               = aws_key_pair.kp.key_name

    tags = {
        Name = "${var.project_id}-server"
    }
}
output "instance_ip" {
  description = "The public IP address of the application server."
  value       = aws_instance.app_server.public_ip
}

output "ssh_private_key_path" {
  description = "Path to the locally saved private key file."
  value = local_file.private_key.filename
}