resource "aws_ecr_repository" "ECR" {
  name = "${var.environment}-${var.repo_name}"

}

