resource "random_id" "bucket_suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "storage" {
  bucket        = "${var.app_name}-storage-${random_id.bucket_suffix.hex}"
  force_destroy = true
  tags          = { Name = "${var.app_name}-storage" }
}

resource "aws_s3_bucket_public_access_block" "storage" {
  bucket                  = aws_s3_bucket.storage.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
