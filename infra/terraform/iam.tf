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

# EC2 role (unique name due to prefix)
resource "aws_iam_role" "ec2_role" {
  name_prefix           = "ec2-app-role-"
  assume_role_policy    = data.aws_iam_policy_document.ec2_assume.json
  force_detach_policies = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "ec2-app-profile-"
  role        = aws_iam_role.ec2_role.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#############################################
# ECS task execution role (for Fargate/EC2)
# Matches ecs.tf depends_on = [aws_iam_role_policy_attachment.ecs_task_exec_attach]
#############################################

# Trust policy for ECS tasks
data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Execution role used by ECS tasks to pull from ECR, write logs, etc.
resource "aws_iam_role" "ecs_task_exec_role" {
  name_prefix           = "ecs-exec-"
  assume_role_policy    = data.aws_iam_policy_document.ecs_tasks_assume.json
  force_detach_policies = true

  lifecycle {
    create_before_destroy = true
  }
}

# EXACT name expected by ecs.tf depends_on
resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
