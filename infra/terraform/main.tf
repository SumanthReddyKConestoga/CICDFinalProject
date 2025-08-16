module "vpc" {
  source           = "./modules/vpc"
  vpc_cidr         = var.vpc_cidr
  public_subnet_1  = var.public_subnet_1
  public_subnet_2  = var.public_subnet_2
  assign_public_ip = var.assign_public_ip
}

module "security" {
  source      = "./modules/security"
  alb_sg_name = "ec2-app-alb-sg"
  app_sg_name = "ec2-app-sg"
  vpc_id      = module.vpc.vpc_id
  ssh_cidr    = var.ssh_cidr
}

module "ec2" {
  source = "./modules/ec2"

  ami_id                    = data.aws_ami.al2023.id
  subnet_id                 = module.vpc.public_subnet_1_id
  app_sg_id                 = module.security.app_sg_id
  instance_type             = var.instance_type
  assign_public_ip          = var.assign_public_ip
  iam_instance_profile_name = aws_iam_instance_profile.ec2_profile.name
  key_name                  = var.key_pair_name          # <-- FIXED
  user_data                 = local.user_data
}

module "alb" {
  source            = "./modules/alb"
  lb_name           = "ec2-app-alb"
  security_group_id = module.security.alb_sg_id
  subnet_ids        = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
  tg_name           = "ec2-app-tg"
  target_port       = 80
  backend_tg_name   = "ec2-app-backend-tg"
  backend_port      = 3000
  vpc_id            = module.vpc.vpc_id
  ec2_instance_id   = module.ec2.instance_id
}
