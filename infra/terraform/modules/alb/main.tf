#############################################
# Application Load Balancer + Target Groups
# EC2-first wiring (listeners -> EC2 TGs)
#############################################

resource "aws_lb" "app_alb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  tags = {
    Name = var.lb_name
  }
}

# ------------------------------
# EC2 Target Group: Frontend
# ------------------------------
resource "aws_lb_target_group" "app_tg" {
  # name_prefix must be <= 6 chars
  name_prefix = "ec2a-"             # old: "ec2-app-"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = var.tg_name
  }
}

# ------------------------------
# EC2 Target Group: Backend API
# ------------------------------
resource "aws_lb_target_group" "backend_tg" {
  name_prefix = "ec2b-"             # old: "ec2-back-"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/api/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = var.backend_tg_name
  }
}

# -----------------------------------------
# ECS/Fargate Target Group: Frontend (IP)
# -----------------------------------------
resource "aws_lb_target_group" "ecs_app_tg" {
  name_prefix = "ecsa-"             # old: "ecs-app-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ecs-app-tg"
  }
}

# -------------------------------------------
# ECS/Fargate Target Group: Backend (IP)
# -------------------------------------------
resource "aws_lb_target_group" "ecs_backend_tg" {
  name_prefix = "ecsb-"             # old: "ecs-back-"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ecs-backend-tg"
  }
}

# -------------------------------------------
# Listeners (EC2-first routing)
# -------------------------------------------
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = aws_lb_listener.app_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# -------------------------------------------
# Attach EC2 instance to EC2 target groups
# -------------------------------------------
resource "aws_lb_target_group_attachment" "app_ec2_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = var.ec2_instance_id
  port             = var.target_port
}

resource "aws_lb_target_group_attachment" "backend_ec2_attachment" {
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id        = var.ec2_instance_id
  port             = var.backend_port
}
