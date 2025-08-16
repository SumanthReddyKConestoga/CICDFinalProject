#############################################
# EC2 Instance (uses existing key pair)
#############################################

# Use the existing EC2 key pair (e.g., FINALCICD); do NOT create/import again
data "aws_key_pair" "deployer" {
  key_name = var.key_pair_name
}

# Amazon Linux 2023 AMI (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    backend_ecr_repo  = var.backend_ecr_repo
    frontend_ecr_repo = var.frontend_ecr_repo
    image_tag         = var.image_tag
    app_port          = var.app_port
    aws_region        = var.aws_region
  })
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type

  # Use outputs from your VPC & Security modules
  subnet_id                  = module.vpc.public_subnet_1_id
  vpc_security_group_ids     = [module.security.app_sg_id]

  associate_public_ip_address = var.assign_public_ip
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  # Existing key pair
  key_name  = data.aws_key_pair.deployer.key_name

  user_data = local.user_data

  tags = {
    Name = "ec2-app-instance"
  }
}
