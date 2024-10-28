resource "aws_s3_bucket" "organization_logo_store_bucket" {
   bucket = "${lower(var.project_name)}-${lower(var.environment)}-organization-logo-store-bucket"
   
  
  tags = {
    Name        = "bucket to store organizations logo"
    Project = var.project_name

  }
}

# provide public access

resource "aws_s3_bucket_public_access_block" "organization_logo_store_public_access" {
  bucket = aws_s3_bucket.organization_logo_store_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# bucket policy

resource "aws_s3_bucket_policy" "organization_logo_store_bucket_policy" {
  bucket = aws_s3_bucket.organization_logo_store_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.organization_logo_store_bucket.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.organization_logo_store_bucket.id}"
      ]
    }
  ]
}
EOF
}


