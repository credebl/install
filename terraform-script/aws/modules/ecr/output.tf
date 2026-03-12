output "ecr_repo_name" {
  value = aws_ecr_repository.ECR.name
}

output "ecr_repo_arn" {
  value = aws_ecr_repository.ECR.arn
}

output "ecr_repo_url" {
  value = aws_ecr_repository.ECR.repository_url

}
