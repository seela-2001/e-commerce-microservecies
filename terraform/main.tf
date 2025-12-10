terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "6.24.0"
        }
    }

    backend "s3" {
        bucket = "flipkart-tf-state-bucket-2"
        key = "dev/terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = var.aws_region
}

# vpc and subnet
resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.project_id}-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.public_subnet_cidr

    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project_id}-public-subnet"
    }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.project_id}-igw"
    }
}

# route table public
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "${var.project_id}-public-rt"
    }
}

# Associate Route Table With Subnet
resource "aws_route_table_association" "pub_assoc" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public_rt.id
}

#  Security Group (Firewall)
resource "aws_security_group" "app_sg" {
    name        = "${var.project_id}-sg"
    description = "Allow SSH, Frontend (3000), Backend (4000)"
    vpc_id      = aws_vpc.main.id

    # SSH
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Frontend
    ingress {
        from_port   = var.frontend_port
        to_port     = var.frontend_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Backend
    ingress {
        from_port   = var.backend_port
        to_port     = var.backend_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Outbound
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


# SSH Key Generation
resource "tls_private_key" "pk" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
    key_name   = "${var.project_id}-key"
    public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "private_key" {
    filename        = "${path.module}/${var.project_id}-key.pem"
    content         = tls_private_key.pk.private_key_pem
    file_permission = "0400"
}

# EC2 Instance
resource "aws_instance" "app_server" {
    ami                    = var.ami_id
    instance_type          = var.ec2_type
    subnet_id              = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    key_name               = aws_key_pair.kp.key_name

    tags = {
        Name = "${var.project_id}-server"
    }
}



output "instance_ip" {
  value = aws_instance.app_server.public_ip
}