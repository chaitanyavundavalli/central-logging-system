# Creates an S3 bucket.
resource "aws_s3_bucket" "test_s3_bucket" {
  bucket = var.s3_bucket_name

  # Tags to identify the bucket's purpose and environment.
  tags = {
    Name        = "test-s3-logs-${var.environment}"
    Environment = var.environment
  }
}

# Configures server-side encryption using AWS KMS for the S3 bucket.
resource "aws_s3_bucket_server_side_encryption_configuration" "test_s3_bucket_encryption" {
  bucket = aws_s3_bucket.test_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.test_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Outputs the ID of the created S3 bucket.
output "s3_bucket_name" {
  value = aws_s3_bucket.test_s3_bucket.id
}
