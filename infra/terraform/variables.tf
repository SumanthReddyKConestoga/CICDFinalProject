variable "public_key_path" {
  type        = string
  description = "Path to your public SSH key file. Place your public key (e.g., id_rsa.pub) in infra/terraform and set this to 'id_rsa.pub'."
  default     = "id_rsa.pub"
}
# variable "app_name" removed — it caused duplicate-declaration errors in CI when Terraform
# loaded multiple files. If you need a project name for external scripts, set it in GitHub
# Actions env or add a uniquely-named variable here (e.g., project_name) and reference it
# from root-only Terraform code.
variable "backend_ecr_repo" {
  type    = string
  # Default points to the expected ECR repo used in this project. Overridden by terraform.tfvars or CI env/secrets.
  default = "019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-backend"
}
variable "frontend_ecr_repo" {
  type    = string
  default = "019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-frontend"
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
