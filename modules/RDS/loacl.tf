locals {
  security_groups = {
    "platform" = var.platform_db_sg_id
    "credo"    = var.credo_db_sg_id
    
  }
}
