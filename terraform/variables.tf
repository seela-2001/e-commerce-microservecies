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

variable "cluster_name" {
    description = "Name of the EKS cluster"
    type = string
}

variable "public_subnet_cidrs" {
    type = string
    description = "List of CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
    type = string
    description = "List of CIDR blocks for private subnets"
}

variable "availability_zones" {
    type = list(string)
    description = "List of availability zones"
}

variable "rds_username" {
    type = string
    description = "RDS username"
}

variable "rds_password" {
    type = string
    description = "RDS password"
}

variable "db_engine" {
    type = string
    description = "RDS database engine"
    # default     = "postgres"
}