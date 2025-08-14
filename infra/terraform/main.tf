# local.name is defined in variables.tf
resource "aws_cloudwatch_log_group" "svc" {
  name              = "/${local.name}/bootstrap"
  retention_in_days = 7
}
