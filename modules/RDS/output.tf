output "RDS_database_host" {
  description = "The database host."
  value = {
    for db_key, db in aws_db_instance.postgres_database : db_key => db.address
  }
}

output "platform_database_name" {
  value = var.databases["platform"].database_name
}

output "RDS_database_port" {
  value = {
    for db_key, db in aws_db_instance.postgres_database : db_key => db.port
  }
}

output "RDS_database_password" {
   value = {
    for db_key, db in aws_db_instance.postgres_database : db_key => db.password
  }
}

output "RDS_database_name" {
  value = {
    for db_key, db in aws_db_instance.postgres_database : db_key => db.db_name
  }
}

output "RDS_database_user" {
  value = {
    for db_key, db in aws_db_instance.postgres_database : db_key => db.username
  }
}
