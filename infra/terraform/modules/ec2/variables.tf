# infra/terraform/modules/ec2/variables.tf
#############################################
# Inputs for EC2 module
#############################################

variable "ami_id" {
  type        = string
  description = "AMI ID for the instance."
}

variable "subnet_id" {
  type        = string
  description = "Subnet where the instance will be placed."
}

variable "app_sg_id" {
  type        = string
  description = "Security Group ID to attach to the instance."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether to associate a public IP."
  default     = true
}

variable "iam_instance_profile_name" {
  type        = string
  description = "Name of the IAM instance profile to attach."
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name (e.g., FINALCICD)."
}

variable "user_data" {
  type        = string
  description = "User data script content."
  default     = ""
}
