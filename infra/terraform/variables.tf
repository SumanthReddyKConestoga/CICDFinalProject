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

variable "key_pair_name" {
  type        = string
  description = "Existing EC2 key pair name (optional). Leave empty for no SSH."
  default     = ""
}

# ECR image URIs; the CI builds/pushes :latest to these.
variable "backend_ecr_repo" {
  type    = string
  default = "019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-backend"
}

variable "frontend_ecr_repo" {
  type    = string
  default = "019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-frontend"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

# Optional if you later enable SSH ingress
variable "ssh_cidr" {
  type        = string
  description = "Your_IP/32 if you enable SSH rule"
  default     = "0.0.0.0/32"
}
