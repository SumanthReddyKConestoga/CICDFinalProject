# infra/terraform/modules/ec2/main.tf
resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.app_sg_id]
  associate_public_ip_address = var.assign_public_ip
  iam_instance_profile        = var.iam_instance_profile_name

  # Only set key_name when provided; otherwise omit so apply won't fail
  key_name = var.key_name != "" ? var.key_name : null

  user_data = var.user_data

  tags = { Name = "ec2-app-instance" }
}
