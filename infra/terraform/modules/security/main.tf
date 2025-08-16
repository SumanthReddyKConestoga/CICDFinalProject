resource "aws_security_group" "alb_sg" {
  name        = var.alb_sg_name
  description = "Allow HTTP to ALB"
  vpc_id      = var.vpc_id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = var.alb_sg_name }
}

resource "aws_security_group" "app_sg" {
  name        = var.app_sg_name
  description = "Allow ALB and SSH to EC2"
  vpc_id      = var.vpc_id
  ingress {
    description     = "App port from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    # only allow ALB security group
    security_groups = [aws_security_group.alb_sg.id]
  }
  # remove public HTTP from app_sg; ALB will be public
  ingress {
    description     = "Backend port from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  # backend access is only allowed from ALB security group
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = var.app_sg_name }
}

// outputs moved to outputs.tf
