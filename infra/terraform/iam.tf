#############################################
# EC2 IAM Role + Instance Profile (Idempotent)
# - Uses name_prefix to avoid "AlreadyExists"
# - Attaches ECR ReadOnly and SSM managed policies
#############################################

# Trust policy for EC2
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# EC2 role (unique name each apply due to prefix)
resource "aws_iam_role" "ec2_role" {
  name_prefix           = "ec2-app-role-"
  assume_role_policy    = data.aws_iam_policy_document.ec2_assume.json
  force_detach_policies = true

  # Safer replacements on re-apply
  lifecycle {
    create_before_destroy = true
  }
}

# Instance profile that EC2 will use
resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "ec2-app-profile-"
  role        = aws_iam_role.ec2_role.name

  lifecycle {
    create_before_destroy = true
  }
}

# Managed policy: pull images from ECR
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Managed policy: SSM (Session Manager, inventory, etc.)
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
