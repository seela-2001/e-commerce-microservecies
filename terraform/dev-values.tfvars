project_id           = "flipkart"
aws_region           = "us-east-1"

vpc_cidr             = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"

frontend_port        = 3000
backend_port         = 4000

ec2_type             = "t3.small"
ami_id               = "ami-0ecb62995f68bb549"

cluster_name         = "depi-gp"
public_subnet_cidrs  = "10.0.1.0/24"
private_subnet_cidrs = "10.0.2.0/24"

availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]

rds_username         = "admin"
rds_password         = "password"