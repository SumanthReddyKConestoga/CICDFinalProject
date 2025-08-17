app_name        = "cicd-final"
aws_region      = "us-east-1"
vpc_cidr        = "10.0.0.0/16"
public_subnet_1 = "10.0.1.0/24"
public_subnet_2 = "10.0.2.0/24"
assign_public_ip = true
ssh_cidr        = "0.0.0.0/0"

app_port        = 3000
backend_port    = 3000
backend_tg_name = "app-tg"

ecr_repo_url    = "019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-backend"
image_tag       = "latest"

key_pair_name   = ""     # leave empty to skip SSH key
public_key_path = ""     # leave empty to skip SSH key
