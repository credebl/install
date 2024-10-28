variable "vpc_id" {}
variable "project_name" {}
variable "environment" {}
variable "credo_db_sg_id" {}
variable "platform_db_sg_id" {}
variable "platform_db_port" {}
variable "credo_db_port" {}
variable "private_db_subnet_ids" {
  type = list(string)
  
}

variable "databases" {
  type = map(object({
      database_name                          = string
      database_master_user                   = string
      database_master_user_password          = string
      allocated_storage                      = number
      database_instance_class                = string
      allow_public_access                    = bool
      use_multiple_availability_zones        = bool
      storage_type                           = string
      storage_iops                           = number
      max_allocated_storage                  = number
      allow_major_version_upgrade            = string
      enable_automatic_minor_version_upgrade = string
      enable_performance_insights            = string
      skip_final_snapshot                    = string
      #  copy_tags_to_snapshot                 = bool
      #  final_snapshot_identifier_prefix      = string  
      #  snapshot_identifier                   = string  
      backup_retention_period                = number
      backup_window                          = string
      maintenance_window                     = string
     

      # Add other variables as needed
    }))
    default = {
      platform = {
        database_name                          = "platform_db"
        database_master_user                   = "platform_user"
        database_master_user_password          = "Pj#hags"
        allocated_storage                      = 100
        database_instance_class                = "db.mg6.large"
        allow_public_access                    = false
        use_multiple_availability_zones        = false
        storage_type                           = "gp2"
        storage_iops                           = 3000
        max_allocated_storage                  = 500
        allow_major_version_upgrade            = 16
        enable_automatic_minor_version_upgrade = true
        enable_performance_insights            = true
        skip_final_snapshot                    = true
        backup_retention_period                = 7
        backup_window                          = "05:30-08:00"
        maintenance_window                     = "Sun:08:00-Sun:10:00"

        # Add other values as needed
      }
      credo = {
        database_name                          = "credo_db"
        database_master_user                   = "credo_user"
        database_master_user_password          = "vafw4vw87#"
        allocated_storage                      = 100
        database_instance_class                = "db.mg6.large"
        allow_public_access                    = false
        use_multiple_availability_zones        = false
        storage_type                           = "gp2"
        storage_iops                           = 3000
        max_allocated_storage                  = 500
        allow_major_version_upgrade            = 16
        enable_automatic_minor_version_upgrade = "yes"
        enable_performance_insights            = "yes"
        skip_final_snapshot                    = true
        backup_retention_period                = 7
        backup_window                          = "05:30-08:00"
        maintenance_window                     = "Sun:08:00-Sun:10:00"

        # Add other values as needed
      }
    }
} 