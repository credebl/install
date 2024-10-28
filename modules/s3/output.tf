
# extracting bucket name 
output "env_file_bucket_id" {
    value = aws_s3_bucket.env_file_bucket.id
  
}

output "demo_shortning_bucket_id" {
    value = aws_s3_bucket.demo_shortning_bucket.id
  
}

output "org_logo_bucket_id" {
  
  value = aws_s3_bucket.organization_logo_store_bucket.id
}

output "env_file_bucket_arn" {
  value = aws_s3_bucket.env_file_bucket.arn
}

output "org_logo_bucket_arn" {
  value = aws_s3_bucket.env_file_bucket.arn
}

output "demo_shortning_bucket_arn" {
  value = aws_s3_bucket.demo_shortning_bucket.arn
}