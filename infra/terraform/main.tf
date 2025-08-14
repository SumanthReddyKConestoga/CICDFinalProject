locals {
  name = var.project_name
}

resource "aws_cloudwatch_log_group" "svc" {
  name              = "/${local.name}/bootstrap"
  retention_in_days = 7
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.svc.name
}
