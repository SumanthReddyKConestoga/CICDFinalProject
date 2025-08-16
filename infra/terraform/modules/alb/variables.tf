variable "lb_name" { type = string }
variable "security_group_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "tg_name" { type = string }
variable "target_port" { type = number }
variable "vpc_id" { type = string }
variable "ec2_instance_id" { type = string }
