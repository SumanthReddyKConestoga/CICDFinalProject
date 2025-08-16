output "instance_id"   { value = aws_instance.app.id }
output "public_ip"     { value = aws_instance.app.public_ip }
output "public_dns"    { value = aws_instance.app.public_dns }
output "app_url"       { value = "http://${aws_instance.app.public_dns}" }
output "storage_bucket" { value = aws_s3_bucket.storage.bucket }
