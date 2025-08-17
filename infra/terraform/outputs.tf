output "instance_id" {
  value = module.ec2.instance_id
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "public_dns" {
  value = module.ec2.public_dns
}

output "app_url" {
  value = "http://${module.ec2.public_dns}:${var.app_port}"
}

output "storage_bucket" {
  value = aws_s3_bucket.storage.bucket
}
