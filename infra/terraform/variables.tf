variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "cicd-final-app"
}
variable "public_key_path" {
  type        = string
  description = "Path to your public SSH key file. Place your public key (e.g., id_rsa.pub) in infra/terraform and set this to 'id_rsa.pub'."
  default     = "id_rsa.pub"
}
variable "app_name" {
  type        = string
  description = "Name of the application for resource naming"
  default     = "cicd-final"
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnet_1" {
  type    = string
  default = "10.0.10.0/24"
}
variable "public_subnet_2" {
  type    = string
  default = "10.0.20.0/24"
}

variable "key_pair_name" {
  type        = string
  description = "Name of an existing EC2 key pair in your AWS account. You must create this in AWS Console > EC2 > Key Pairs if it does not exist."
  default     = "FINALCICD"
}
variable "ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH (use YOUR_IP/32)"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# Your app listens on 3000 locally; keep it consistent
variable "app_port" {
  type    = number
  default = 3000
}

# ECR repo URL, e.g. 019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-backend
variable "ecr_repo_url" {
  type = string
}
variable "image_tag" {
  type    = string
  default = "latest"
}

variable "assign_public_ip" {
  type    = bool
  default = true
}
