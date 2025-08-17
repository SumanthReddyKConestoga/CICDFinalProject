variable "app_name" {
  description = "Logical application name prefix."
  type        = string
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
  description = "Existing EC2 key pair name"
  type        = string
  default     = "FINALCICD"
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH (use YOUR_IP/32)"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_port" {
  description = "Port the app/NGINX will listen on"
  type        = number
  default     = 3000
}

variable "assign_public_ip" {
  description = "Whether instance/subnets map public IPs"
  type        = bool
  default     = true
}

/* Optional (present in your .tfvars). Safe to keep even if unused. */
variable "ecr_repo_url" {
  type    = string
  default = ""
}

variable "image_tag" {
  type    = string
  default = "latest"
}
