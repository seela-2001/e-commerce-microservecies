resource "aws_security_group" "alb_sg" {
  name        = "${var.project_id}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS (443) from anywhere"
    from_port   = 443
    to_port     = 443
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
    Name = "${var.project_id}-alb-sg"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${var.project_id}-app-sg"
  description = "Security group for application servers (EC2)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ALB traffic to backend port"
    from_port   = var.backend_port
    to_port     = var.backend_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id] 
  }

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
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
    Name = "${var.project_id}-app-sg"
  }
}

resource "aws_instance" "app_server" {
    count         = length(var.availability_zones) 

    ami                    = var.ami_id
    instance_type          = var.ec2_type
    subnet_id              = aws_subnet.public[count.index].id
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    key_name               = aws_key_pair.kp.key_name
    
    tags = {
        Name = "${var.project_id}-server-${count.index}"
    }
}

resource "aws_lb" "app_alb" {
  name               = "${var.project_id}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id 

  tags = {
    Name = "${var.project_id}-app-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_id}-tg"
  port     = var.backend_port 
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/" 
    protocol            = "HTTP"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  # Creates one attachment for every EC2 instance
  count            = length(aws_instance.app_server)
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server[count.index].id
  port             = var.backend_port
}

resource "tls_private_key" "pk" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
    key_name   = "${var.project_id}-key-1"
    public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "private_key" {
    filename        = "${path.module}/${var.project_id}-key.pem"
    content         = tls_private_key.pk.private_key_pem
    file_permission = "0400" 
}

output "load_balancer_dns" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.app_alb.dns_name
}

output "ssh_private_key_path" {
  description = "Path to the locally saved private key file."
  value = local_file.private_key.filename
}