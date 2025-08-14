variable "project_name" {
  description = "Project/system name prefix"
  type        = string
  default     = "cicd-final"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account for ECR registry"
  type        = string
}

variable "backend_repo" {
  description = "ECR repo name for backend"
  type        = string
  default     = "cicd-final-backend"
}

variable "image_tag" {
  description = "Image tag to deploy"
  type        = string
  default     = "latest"
}

variable "db_password" {
  description = "DB password for MySQL sidecar"
  type        = string
  sensitive   = true
}

locals {
  registry = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  name     = var.project_name
}

# --- ECS/Service knobs ---
variable "container_port" {
  description = "Backend container port"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks"
  type        = number
  default     = 1
}

# --- EC2 deploy knobs ---
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "repo_url" {
  type    = string
  default = "https://github.com/SumanthReddyKConestoga/CICDFinalProject.git"
}

variable "branch" {
  type    = string
  default = "main"
}

variable "cw_log_group_ec2" {
  type    = string
  default = "/cicd-final/ec2"
}
