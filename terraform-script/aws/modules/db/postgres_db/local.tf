locals {
  # Filter services that need databases first
  db_services = [
    for service in var.SERVICE_CONFIG.WITH_PORT :
    service if contains(["MEDIATOR", "CREDO", "API_GATEWAY", "KEYCLOAK"], service.SERVICE_NAME)
  ]

  # Create configurations only for filtered services
  db_configs = {
    for service in local.db_services :
    service.SERVICE_NAME => {
      db_name           = "${service.SERVICE_NAME}_db"
      username          = lower("${service.SERVICE_NAME}_user")
      allocated_storage = 50
      iops              = 1000
      aries_db          = var.aries_db
      platform_db       = var.platform_db
      db_sg_id          = lookup(var.db_sg_ids, service.SERVICE_NAME, null)
      rds_proxy_sg_ids  = lookup(var.rds_proxy_sg_ids, service.SERVICE_NAME, null)
    }
  }
}

