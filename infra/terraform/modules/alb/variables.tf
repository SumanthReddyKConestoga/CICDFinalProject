# ===============================
# ALB / Target Groups – Variables
# ===============================

variable "lb_name" {
  description = "Name for the Application Load Balancer."
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID attached to the ALB."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets (IDs) where the ALB will be placed."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the ALB and Target Groups live."
  type        = string
}

variable "ec2_instance_id" {
  description = "EC2 instance ID to attach to the EC2 target groups."
  type        = string
}

variable "target_port" {
  description = "Port exposed by the frontend on the EC2 instance."
  type        = number
  default     = 80
}

variable "tg_name" {
  description = "Friendly tag value for the EC2 frontend target group (tag only)."
  type        = string
  default     = "ec2-app-tg"
}

variable "backend_port" {
  description = "Port exposed by the backend API on the EC2 instance."
  type        = number
  default     = 3000
}

variable "backend_tg_name" {
  description = "Friendly tag value for the EC2 backend target group (tag only)."
  type        = string
  default     = "ec2-backend-tg"
}
