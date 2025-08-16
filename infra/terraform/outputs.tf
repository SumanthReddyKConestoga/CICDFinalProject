output "public_ip" {
  value = aws_instance.app.public_ip
}

output "app_url" {
  description = "Primary application URL (ALB DNS)"
  value       = module.alb.app_alb_dns_name
}

output "legacy_ec2_url" {
  description = "Legacy EC2 URL (kept for compatibility)"
  value       = "http://${aws_instance.app.public_ip}:${var.app_port}"
}
