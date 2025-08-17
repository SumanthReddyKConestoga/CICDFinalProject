aws_region       = "us-east-1"
key_pair_name    = "FINALCICD2"        # or whatever key you created
ssh_cidr         = "24.141.163.126/32" # e.g., "99.88.77.66/32"
app_port         = 3000                # must match how your app listens
assign_public_ip = true

ecr_repo_url = "019773930547.dkr.ecr.us-east-1.amazonaws.com/cicd-final-backend"
image_tag    = "latest"
