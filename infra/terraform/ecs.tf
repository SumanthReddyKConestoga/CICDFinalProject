#############################################
# ECS Cluster
#############################################
resource "aws_ecs_cluster" "app" {
  name = "cicd-final-cluster"
}

#############################################
# Task Definitions (use execution role from iam.tf)
#############################################
resource "aws_ecs_task_definition" "backend" {
  family                   = "cicd-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([
    {
      name         = "backend"
      image        = var.backend_ecr_repo
      essential    = true
      portMappings = [{ containerPort = 3000, protocol = "tcp" }]
    }
  ])
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "cicd-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([
    {
      name         = "frontend"
      image        = var.frontend_ecr_repo
      essential    = true
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
    }
  ])
}

#############################################
# Security group for ECS tasks
#############################################
resource "aws_security_group" "ecs_tasks_sg" {
  name   = "ecs-tasks-sg"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ALB -> tasks on 80
  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.security.alb_sg_id]
  }

  # Allow ALB -> backend on 3000
  ingress {
    description     = "Allow backend port from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [module.security.alb_sg_id]
  }
}

#############################################
# ECS Services (WAIT for ALB module)
#############################################
resource "aws_ecs_service" "backend" {
  name            = "cicd-backend-svc"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.ecs_backend_tg_arn
    container_name   = "backend"
    container_port   = 3000
  }

  # Ensure the ALB (listeners/rules) is fully created before this service
  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_exec_attach,
    module.alb
  ]
}

resource "aws_ecs_service" "frontend" {
  name            = "cicd-frontend-svc"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.ecs_app_tg_arn
    container_name   = "frontend"
    container_port   = 80
  }

  # Ensure the ALB (listeners/rules) is fully created before this service
  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_exec_attach,
    module.alb
  ]
}
