variable "ami_id"  { type = string }
variable "subnet_id"  { type = string }
variable "app_sg_id"  { type = string }

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "assign_public_ip" {
  type    = bool
  default = true
}

variable "iam_instance_profile_name" {
  type = string
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name; leave empty to skip attaching a key."
  default     = ""
}

variable "user_data" {
  type    = string
  default = ""
}
