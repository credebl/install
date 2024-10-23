resource "aws_s3_bucket" "demo_shortning_bucket" {
    bucket = "${lower(var.project_name)}-${var.environment}-demo-shortning-bucket"

    tags = {
    Name        = "shortning url storage bucket used for connection"
    Project = var.project_name
  }
  
}


# provide public access

resource "aws_s3_bucket_public_access_block" "demo_shortning_bucket_access" {
  bucket = aws_s3_bucket.demo_shortning_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# bucket policy

resource "aws_s3_bucket_policy" "demo_shortning_bucket_policy" {
  bucket = aws_s3_bucket.demo_shortning_bucket.id

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
        "arn:aws:s3:::${aws_s3_bucket.demo_shortning_bucket.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.demo_shortning_bucket.id}"
      ]
    }
  ]
}
EOF
}

