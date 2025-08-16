# ===========================
# Global / project parameters
# ===========================

variable "app_name" {
  type        = string
  description = "Logical application name prefix used by ECS/EC2 resources."
  default     = "cicd-final"
}

variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "us-east-1"
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP to EC2 instances."
  default     = true
}

# Optional feature toggle (if you keep ecs.tf but don't want to deploy ECS right now)
variable "enable_ecs" {
  type        = bool
  description = "Whether to create ECS resources."
  default     = false
}

# ===========================
# Networking
# ===========================

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR."
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "public_subnet_1" {
  type        = string
  description = "CIDR for public subnet A."
  default     = "10.0.10.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_1, 0))
    error_message = "public_subnet_1 must be a valid CIDR block."
  }
}

variable "public_subnet_2" {
  type        = string
  description = "CIDR for public subnet B."
  default     = "10.0.20.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_2, 0))
    error_message = "public_subnet_2 must be a valid CIDR block."
  }
}

variable "ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH (use YOUR_IP/32 for security; 0.0.0.0/0 for demo only)."
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr))
    error_message = "ssh_cidr must be a valid CIDR (e.g., 1.2.3.4/32)."
  }
}

# ===========================
# Compute / app
# ===========================

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "app_port" {
  type        = number
  description = "Application port exposed by the backend on EC2."
  default     = 3000

  validation {
    condition     = var.app_port >= 1 && var.app_port <= 65535
    error_message = "app_port must be between 1 and 65535."
  }
}

variable "key_pair_name" {
  type        = string
  description = "Existing EC2 key pair name (e.g., FINALCICD). Leave empty to launch without SSH key."
  default     = ""
}

variable "public_key_path" {
  type        = string
  description = "Path to your public SSH key file relative to infra/terraform (e.g., id_rsa.pub)."
  default     = "id_rsa.pub"
}

# ===========================
# Container images / ECR
# ===========================

variable "backend_ecr_repo" {
  type        = string
  description = "Full ECR repo URI for backend image."
  default     = "019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-backend"
}

variable "frontend_ecr_repo" {
  type        = string
  description = "Full ECR repo URI for frontend image."
  default     = "019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-frontend"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to deploy."
  default     = "latest"
}

# Optional convenience var; leave empty if unused.
variable "ecr_repo_url" {
  type        = string
  description = "Generic ECR repo URL if a single image URI is needed (optional)."
  default     = ""
}
