output "secret_arn" {
  value = aws_secretsmanager_secret.db_password.arn
  description = "ARN of the secret containing DB credentials"
}

output "secret_name" {
  value = aws_secretsmanager_secret.db_password.name
  description = "Name of the secret containing DB credentials"
}

# # Get password
# aws secretsmanager get-secret-value --secret-id "project-env-credo-db-password" --query SecretString --output text | jq -r '.password'

# # Get username
# aws secretsmanager get-secret-value --secret-id "project-env-credo-db-password" --query SecretString --output text | jq -r '.username'

# # Get host/endpoint
# aws secretsmanager get-secret-value --secret-id "project-env-credo-db-password" --query SecretString --output text | jq -r '.host'

# # Get port
# aws secretsmanager get-secret-value --secret-id "project-env-credo-db-password" --query SecretString --output text | jq -r '.port'

# # Get database name
# aws secretsmanager get-secret-value --secret-id "project-env-credo-db-password" --query SecretString --output text | jq -r '.dbname'

# # Get engine
# aws secretsmanager get-secret-value --secret-id "project-env-credo-db-password" --query SecretString --output text | jq -r '.engine'
