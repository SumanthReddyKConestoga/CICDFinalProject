# variables.tf
variable "repo_name" {
  description = "ECR repo name for the backend image"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Optional, if your code references it
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
