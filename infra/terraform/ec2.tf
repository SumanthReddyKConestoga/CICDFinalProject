########################################
# Networking (use Default VPC) – v5-safe
########################################

# Default VPC (provider v5+)
data "aws_vpc" "default" {
  default = true
}

# Default subnets inside that VPC (one per AZ)
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  # Optional but helps select the default-for-az subnets
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

########################################
# CloudWatch Logs group for containers
########################################
resource "aws_cloudwatch_log_group" "ec2" {
  name              = var.cw_log_group_ec2
  retention_in_days = 7
}

########################################
# IAM Role for EC2: SSM + CloudWatch Logs
########################################
resource "aws_iam_role" "ec2" {
  name = "${local.name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cwlogs" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name}-ec2-profile"
  role = aws_iam_role.ec2.name
}

########################################
# Security Group (HTTP open)
########################################
resource "aws_security_group" "web" {
  name        = "${local.name}-web-sg"
  description = "Allow HTTP"
  vpc_id      = data.aws_vpc.default.id

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
}

########################################
# Find latest Amazon Linux 2023 AMI
########################################
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

########################################
# EC2 Instance with user_data
########################################
locals {
  app_dir = "/opt/app"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default_vpc_subnets.ids[0]
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  tags = {
    Name    = "${local.name}-ec2"
    Project = local.name
  }

  user_data = <<-BASH
    #!/bin/bash
    set -eux

    dnf update -y
    dnf install -y docker git curl

    systemctl enable --now docker
    usermod -aG docker ec2-user || true

    # Install docker compose v2
    curl -L "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    mkdir -p ${local.app_dir}
    cd ${local.app_dir}

    # Clone or refresh repo
    if [ ! -d app ]; then
      git clone "${var.repo_url}" app
    fi
    cd app
    git fetch --all
    git checkout ${var.branch}
    git reset --hard origin/${var.branch}

    # Provide .env (DB password from Terraform var)
    echo "DB_PASSWORD=${var.db_password}" > .env

    # Force CloudWatch Logs for containers via override file
    cat > docker-compose.override.yml <<'EOF'
    services:
      backend:
        logging:
          driver: awslogs
          options:
            awslogs-region: ${var.aws_region}
            awslogs-group: ${var.cw_log_group_ec2}
            awslogs-stream: backend
      frontend:
        logging:
          driver: awslogs
          options:
            awslogs-region: ${var.aws_region}
            awslogs-group: ${var.cw_log_group_ec2}
            awslogs-stream: frontend
      db:
        logging:
          driver: awslogs
          options:
            awslogs-region: ${var.aws_region}
            awslogs-group: ${var.cw_log_group_ec2}
            awslogs-stream: db
    EOF

    # Publish on port 80 (optional reverse proxy if your compose exposes 8081/3000)
    # If your frontend already binds 80, you can skip this.
    if ! ss -tulpen | grep -q ':80 '; then
      dnf install -y iptables-services
      systemctl enable --now iptables
      iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8081 || true
      service iptables save || true
    fi

    # Bring up the stack
    /usr/local/bin/docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d --build
  BASH
}

########################################
# Outputs
########################################
output "ec2_instance_id" { value = aws_instance.web.id }
output "ec2_public_ip" { value = aws_instance.web.public_ip }
output "ec2_public_dns" { value = aws_instance.web.public_dns }
output "ec2_log_group" { value = aws_cloudwatch_log_group.ec2.name }
