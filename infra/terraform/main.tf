# User data used to bootstrap a simple NGINX site on your chosen port
locals {
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    aws_region       = var.aws_region
    app_port         = var.app_port
    backend_ecr_repo = var.ecr_repo_url
    image_tag        = var.image_tag
  })
}



module "ec2" {
  source = "./modules/ec2"

  ami_id                    = data.aws_ami.al2023.id
  instance_type             = var.instance_type
  subnet_id                 = aws_subnet.public_1.id
  app_sg_id                 = aws_security_group.app_sg.id
  iam_instance_profile_name = aws_iam_instance_profile.ec2_profile.name
  key_name                  = var.key_pair_name
  assign_public_ip          = var.assign_public_ip
  user_data                 = local.user_data

  depends_on = [
    aws_route.default_inet,
    aws_iam_instance_profile.ec2_profile
  ]
}
