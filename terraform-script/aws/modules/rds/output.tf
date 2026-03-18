output "secret_arn" {
  value = aws_secretsmanager_secret.db_password.arn
  description = "ARN of the secret containing DB credentials"
}

output "secret_name" {
  value = aws_secretsmanager_secret.db_password.name
  description = "Name of the secret containing DB credentials"
}

output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
  description = "RDS instance endpoint"
  sensitive = true  
}

output "rds_port" {
  value = aws_db_instance.rds_instance.port
  description = "RDS instance port"
  sensitive = true
}