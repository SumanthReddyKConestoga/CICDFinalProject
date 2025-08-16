resource "aws_ecs_cluster" "app" {
  name = "cicd-final-cluster"
}

# IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_exec_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Task definition for backend
resource "aws_ecs_task_definition" "backend" {
  family                   = "cicd-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_ecr_repo
      portMappings = [{ containerPort = 3000, protocol = "tcp" }]
      essential = true
    }
  ])
}

# Task definition for frontend
resource "aws_ecs_task_definition" "frontend" {
  family                   = "cicd-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_ecr_repo
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
      essential = true
    }
  ])
}

# Security group for ECS tasks to allow outbound to internet and inbound from ALB
resource "aws_security_group" "ecs_tasks_sg" {
  name   = "ecs-tasks-sg"
  vpc_id = module.vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow ALB -> tasks on 80 and 3000 (temporary open to public for demo)
  # Allow ALB -> tasks on 80 and 3000 (only from ALB SG)
  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.security.alb_sg_id]
  }
  ingress {
    description     = "Allow backend port from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [module.security.alb_sg_id]
  }
}

# Backend service
resource "aws_ecs_service" "backend" {
  name            = "cicd-backend-svc"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.ecs_backend_tg_arn
    container_name   = "backend"
    container_port   = 3000
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_exec_attach]
}

# Frontend service
resource "aws_ecs_service" "frontend" {
  name            = "cicd-frontend-svc"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
    security_groups = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.ecs_app_tg_arn
    container_name   = "frontend"
    container_port   = 80
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_exec_attach]
}
