output "project" {
  value = var.project_name
}

output "aws_region" {
  value = var.aws_region
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.svc.name
}

output "alb_dns_name" {
  value       = aws_lb.app.dns_name
  description = "Public ALB DNS to hit /api/health"
}

output "service_name" {
  value = aws_ecs_service.api.name
}

output "image_used" {
  value = "${local.registry}/${var.backend_repo}:${var.image_tag}"
}
