resource "aws_s3_bucket" "application_data" {
  bucket_prefix = "cloud-security-pbl-data-"

  tags = {
    Name        = "Cloud Security PBL Application Data"
    DataPurpose = "Application data storage"
  }
}

resource "aws_s3_bucket_public_access_block" "application_data" {
  bucket = aws_s3_bucket.application_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "application_data" {
  bucket = aws_s3_bucket.application_data.id

  versioning_configuration {
    status = "Enabled"
  }
}