terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws    = { source = "hashicorp/aws",    version = "~> 5.100" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use DEFAULT VPC to avoid IGW/VPC quotas
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Latest Amazon Linux 2023 AMI (already in your repo as ami.tf too; keep one)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"   values = ["al2023-ami-*-x86_64"] }
  filter { name = "state"  values = ["available"] }
}

# Security Group: expose only 80 to the world. Backend stays internal via Docker network.
resource "aws_security_group" "app_sg" {
  name        = "ec2-app-sg"
  description = "Allow HTTP to Nginx; all egress"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OPTIONAL SSH: uncomment and set var.ssh_cidr if you need it
  # ingress {
  #   description = "SSH"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = [var.ssh_cidr]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ec2-app-sg" }
}

# S3 bucket (for “storage” requirement). Not used by runtime path; created for compliance/demo.
resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "storage" {
  bucket        = "cicd-final-${random_id.suffix.hex}"
  force_destroy = true
  tags = { Purpose = "Course-Storage", Owner = "CICD-Final" }
}

# --- user_data that pulls images from ECR and runs both containers
locals {
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    region             = var.aws_region
    backend_ecr_repo   = var.backend_ecr_repo
    frontend_ecr_repo  = var.frontend_ecr_repo
    image_tag          = var.image_tag
  })
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default_vpc_subnets.ids[0]
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  # omit key if you don't have one
  key_name  = var.key_pair_name != "" ? var.key_pair_name : null
  user_data = local.user_data

  tags = { Name = "ec2-app-instance" }
}
