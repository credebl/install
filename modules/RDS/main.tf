resource "aws_db_instance" "postgres_database" {
  for_each = var.databases

  identifier          = "${var.environment}-${each.key}"
  engine              = "postgres"
  instance_class      = each.value.database_instance_class
  publicly_accessible = each.value.allow_public_access
  multi_az            = each.value.use_multiple_availability_zones
  port                = each.key == "platform" ? var.platform_db_port : var.credo_db_port

  db_subnet_group_name = aws_db_subnet_group.postgres_database_subnet_group.name

  vpc_security_group_ids = [each.key == "platform" ? var.platform_db_sg_id : var.credo_db_sg_id] # Lookup security group ID based on the value in each database configuration


  storage_type                 = each.value.storage_type
  iops                         = each.value.storage_iops
  allocated_storage            = each.value.allocated_storage
  max_allocated_storage        = each.value.max_allocated_storage
  db_name                      = each.value.database_name
  username                     = each.value.database_master_user
  password                     = each.value.database_master_user_password
  allow_major_version_upgrade  = each.value.allow_major_version_upgrade == "yes" ? true : false
  auto_minor_version_upgrade   = each.value.enable_automatic_minor_version_upgrade == "yes" ? true : false
  performance_insights_enabled = each.value.enable_performance_insights == "yes" ? true : false
  backup_retention_period      = each.value.backup_retention_period
  backup_window                = each.value.backup_window
  maintenance_window           = each.value.maintenance_window
  skip_final_snapshot          = true
 

  tags = {
    Name = "${var.environment}-${each.key}-${each.value.database_name}"
  }

}
