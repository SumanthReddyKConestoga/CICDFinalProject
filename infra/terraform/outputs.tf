# EC2 surfacing via module outputs
output "instance_id" {
  value       = module.ec2.instance_id
  description = "EC2 instance ID"
}

output "public_ip" {
  value       = module.ec2.public_ip
  description = "EC2 public IP"
}

output "public_dns" {
  value       = module.ec2.public_dns
  description = "EC2 public DNS"
}

# ALB pass-throughs (module.alb already exports these)
output "app_alb_arn" {
  value       = module.alb.app_alb_arn
  description = "ARN of the application load balancer"
}

output "app_alb_dns_name" {
  value       = module.alb.app_alb_dns_name
  description = "DNS name of the application load balancer"
}

# Friendly URLs for demo
output "app_url" {
  value       = "http://${module.alb.app_alb_dns_name}"
  description = "Frontend URL (ALB)"
}

output "api_health_url" {
  value       = "http://${module.alb.app_alb_dns_name}/api/health"
  description = "Backend health endpoint (via ALB path rule)"
}
