resource "aws_s3_bucket" "url_link_bucket" {
  bucket = "${lower(var.project_name)}-${lower(var.environment)}-url-link-bucket"

  tags = {
    Name    = "Bucket to store organization logos"
    Project = var.project_name
  }
}

# Allow public read access
resource "aws_s3_bucket_public_access_block" "url_link_bucket_public_access" {
  bucket                  = aws_s3_bucket.url_link_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy to allow public read and specific access for the app
resource "aws_s3_bucket_policy" "url_link_bucket_policy" {
  bucket = aws_s3_bucket.url_link_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.url_link_bucket.id}/*"
    },
    {
      "Sid": "AppSpecificAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.ecs_tasks_role_arn}"
      },
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.url_link_bucket.id}/*"
      ]
    }
  ]
}
EOF
}
