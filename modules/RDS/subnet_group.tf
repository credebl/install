resource "aws_db_subnet_group" "postgres_database_subnet_group" {
  name        = "${var.environment}_db_subnet_group"
  description = "Subnet group for ${var.project_name} PostgreSQL database instance with deployment of  ${var.environment} environment."
  subnet_ids  = var.private_db_subnet_ids

  tags = {
    Name = "db-subnet-group-${var.project_name}-${var.environment}"
  }
}
