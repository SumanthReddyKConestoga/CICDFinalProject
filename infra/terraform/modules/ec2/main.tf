resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.app_sg_id]
  associate_public_ip_address = var.assign_public_ip
  iam_instance_profile        = var.iam_instance_profile_name
  key_name                    = var.key_name
  user_data                   = var.user_data

  metadata_options {
    http_tokens = "required"
  }

  tags = { Name = "ec2-app-instance" }
}
