variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "subnet_id" { type = string }
variable "app_sg_id" { type = string }
variable "iam_instance_profile_name" { type = string }
variable "key_name" { type = string }
variable "assign_public_ip" { type = bool }
variable "user_data" { type = string }
