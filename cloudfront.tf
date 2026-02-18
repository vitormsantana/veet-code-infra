# -------------------------------
# S3 bucket for Hammocker images (public)
# -------------------------------
resource "aws_s3_bucket" "hammocker_public" {
  bucket = "hammocker-public-${var.account_id}"

  tags = {
    Name        = "hammocker-public"
    Environment = "prod"
  }
}

resource "aws_s3_bucket_ownership_controls" "hammocker_public" {
  bucket = aws_s3_bucket.hammocker_public.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Allow public access (for image sharing)
resource "aws_s3_bucket_public_access_block" "hammocker_public" {
  bucket                  = aws_s3_bucket.hammocker_public.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public read policy (only for object GET)
data "aws_iam_policy_document" "public_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.hammocker_public.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.hammocker_public.id
  policy = data.aws_iam_policy_document.public_read.json
}

# -------------------------------
# Outputs
# -------------------------------
output "bucket_name" {
  value       = aws_s3_bucket.hammocker_public.bucket
  description = "Name of the public S3 bucket"
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.hammocker_public.bucket_regional_domain_name
  description = "Public S3 bucket domain name"
}
