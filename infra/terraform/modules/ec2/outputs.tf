# infra/terraform/modules/ec2/outputs.tf
output "instance_id" {
  value       = aws_instance.app.id
  description = "ID of the created EC2 instance."
}
