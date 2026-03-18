data "aws_rds_engine_version" "latest_postgres" {
  engine = "postgres"
}

resource "random_string" "db_passwords" {
  for_each = toset(["master", "keycloak", "credebl"])
  length   = 16
  upper    = true
  numeric  = true
  special  = false
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}-${var.environment}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    # Master credentials
    username = var.db_username
    password = random_string.db_passwords["master"].result
    engine   = "postgres"
    host     = aws_db_instance.rds_instance.endpoint
    port     = aws_db_instance.rds_instance.port
    dbname   = var.db_name
    
    # Keycloak database credentials
    keycloak_username = "keycloak_user"
    keycloak_password = random_string.db_passwords["keycloak"].result
    keycloak_dbname = "keycloak"
    keycloak_url = "postgresql://keycloak_user:${random_string.db_passwords["keycloak"].result}@${aws_db_instance.rds_instance.endpoint}:${aws_db_instance.rds_instance.port}/keycloak"
    
    # CREDEBL database credentials
    credebl_username = "credebl_user"
    credebl_password = random_string.db_passwords["credebl"].result
    credebl_dbname = "credebl"
    credebl_url = "postgresql://credebl_user:${random_string.db_passwords["credebl"].result}@${aws_db_instance.rds_instance.endpoint}:${aws_db_instance.rds_instance.port}/credebl"
  })
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = lower("${var.project_name}-${var.environment}-db-subnet-group")
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier            = lower("${var.project_name}-${var.environment}-db")
  instance_class        = var.db_instance_class
  engine                = "postgres"
  engine_version        = data.aws_rds_engine_version.latest_postgres.version
  allocated_storage     = var.db_storage_size
  storage_type          = var.storage_type
  max_allocated_storage = var.max_db_storage_size
  iops                  = var.storage_type == "io1" || var.storage_type == "io2" ? var.db_iops : null
  multi_az              = true
  username              = var.db_username
  password              = random_string.db_passwords["master"].result
  db_name               = var.db_name
  db_subnet_group_name  = aws_db_subnet_group.db_subnet_group.name

  vpc_security_group_ids = [var.db_sg_id]
  
  deletion_protection   = true
  maintenance_window = "sun:03:00-sun:04:00"
  backup_window      = "02:00-03:00"
  
  backup_retention_period               = 15
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  performance_insights_enabled          = true
  performance_insights_retention_period = 31
  skip_final_snapshot                   = false
  final_snapshot_identifier             = "${var.project_name}-${var.environment}-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
  }
}
