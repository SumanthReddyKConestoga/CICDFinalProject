# ============================
# ALB / Target Groups Outputs
# ============================

output "ecs_app_tg_arn" {
  description = "ARN of the ECS (Fargate/IP) frontend target group."
  value       = aws_lb_target_group.ecs_app_tg.arn
}

output "ecs_backend_tg_arn" {
  description = "ARN of the ECS (Fargate/IP) backend API target group."
  value       = aws_lb_target_group.ecs_backend_tg.arn
}

output "app_tg_arn" {
  description = "ARN of the EC2 instance target group for the frontend."
  value       = aws_lb_target_group.app_tg.arn
}

output "backend_tg_arn" {
  description = "ARN of the EC2 instance target group for the backend API."
  value       = aws_lb_target_group.backend_tg.arn
}

output "app_alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.app_alb.arn
}

output "app_alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.app_alb.dns_name
}
