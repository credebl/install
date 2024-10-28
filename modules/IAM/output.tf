output "org_logo_bucket_access_policy_arn" {
    value = aws_iam_policy.org_logo_bucket_access_iam_policy.arn
  
}

output "demo_shortning_bucket_access_policy" {
    value = aws_iam_policy.demo_shortning_bucket_access_iam_policy.arn
  
}

output "demo_shortning_iam_user" {
    value = aws_iam_user.demo_shortning_iam_user.name
  
}

output "org_logo_iam_user" {
    value = aws_iam_user.org_logo_iam_user
  
}

output "ecs_tasks_execution_role_arn" {
  value = aws_iam_role.ecs_tasks_execution_role.arn
}


# Output the IAM user's access key ID
output "org_logo_iam_user_access_key_id" {
  value = aws_iam_access_key.org_logo_iam_user_access_key.id
}

# Output the IAM user's secret access key
output "org_logo_iam_user_secret_access_key" {
  value = aws_iam_access_key.org_logo_iam_user_access_key.secret
}

# Output the IAM user's access key ID
output "demo_shortning_iam_user_access_key_id" {
  value = aws_iam_access_key.demo_shortning_iam_user_access_key.id
}

# Output the IAM user's secret access key
output "demo_shortning_iam_user_secret_access_key" {
  value = aws_iam_access_key.demo_shortning_iam_user_access_key.secret
}


output "ssm_role_name" {
  value = aws_iam_role.ssm_role.name
}