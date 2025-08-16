resource "aws_key_pair" "deployer" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}
locals {
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    ecr_repo_url = var.ecr_repo_url
    image_tag    = var.image_tag
    app_port     = var.app_port
    aws_region   = var.aws_region
  })
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = var.assign_public_ip
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = aws_key_pair.deployer.key_name
  user_data                   = local.user_data

  tags = { Name = "ec2-app-instance" }
}
