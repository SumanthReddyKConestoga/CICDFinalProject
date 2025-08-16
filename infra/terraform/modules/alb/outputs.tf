output "ecs_app_tg_arn" {
  value = aws_lb_target_group.ecs_app_tg.arn
}

output "ecs_backend_tg_arn" {
  value = aws_lb_target_group.ecs_backend_tg.arn
}

output "app_tg_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend_tg.arn
}

output "app_alb_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.app_alb.arn
}

output "app_alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.app_alb.dns_name
}
