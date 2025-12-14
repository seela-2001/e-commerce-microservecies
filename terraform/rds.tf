resource "aws_security_group" "rds" {
  name        = "${var.project_id}-rds-sg"
  description = "Allow inbound traffic from EKS worker nodes to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL access from EKS Nodes"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_eks_node_group.private.security_group_id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_id}-rds-sg"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.project_id}-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Name = "${var.project_id}-rds-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${var.project_id}-db"
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.t3.small"
  username             = var.rds_username
  password             = var.rds_password
  parameter_group_name = "default.postgres15"

  multi_az             = true 
  
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true 

  tags = {
    Name = "${var.project_id}-db"
  }
}