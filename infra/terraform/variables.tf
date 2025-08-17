# App & image
variable "app_name" {
  type    = string
  default = "cicd-final"
}
variable "app_port" {
  type    = number
  default = 3000
}
variable "ecr_repo_url" {
  type    = string
  default = "019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-backend"
}
variable "image_tag" {
  type    = string
  default = "latest"
}
variable "repo_name" {
  type    = string
  default = "cicd-final-backend"
} # harmless if unused

# AWS / instance
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "assign_public_ip" {
  type    = bool
  default = true
}

# Networking
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnet_1" {
  type    = string
  default = "10.0.1.0/24"
}
variable "public_subnet_2" {
  type    = string
  default = "10.0.2.0/24"
}
variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
} # tighten later

# EC2 key pair (optional; set empty to skip)
variable "key_pair_name" {
  type    = string
  default = ""
}
variable "public_key_path" {
  type    = string
  default = ""
}

# ALB / backend
variable "backend_port" {
  type    = number
  default = 3000
}
variable "backend_tg_name" {
  type    = string
  default = "app-tg"
}
