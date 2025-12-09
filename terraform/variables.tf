variable "project_id" {
    type        = string
    description = "Project prefix"
}

variable "aws_region" {
    type        = string
    description = "AWS region"
}

variable "vpc_cidr" {
    type        = string
    description = "CIDR for the VPC"
}

variable "public_subnet_cidr" {
    type        = string
    description = "CIDR for the public subnet"
}

variable "frontend_port" {
    type        = number
    description = "Port for frontend container"
}

variable "backend_port" {
    type        = number
    description = "Port for backend container"
}

variable "ec2_type" {
    type        = string
    description = "EC2 instance type"
}

variable "ami_id" {
    type        = string
    description = "AMI ID for EC2"
}
