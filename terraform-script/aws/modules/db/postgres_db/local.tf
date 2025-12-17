locals {
  # Filter services that need databases first
  db_services = [
    for service in var.SERVICE_CONFIG.WITH_PORT :
    service if contains(["mediator", "api-gateway", "keycloak"], service.SERVICE_NAME)
  ]

  discovered_service_names = [
    for service in local.db_services :
    service.SERVICE_NAME
  ]

  # Union of discovered services and extra DB services
  all_db_service_names = toset(
    concat(
      local.discovered_service_names,
      var.extra_db_services
    )
  )

  # Create configurations only for filtered services
  db_configs = {
    for service_name in local.all_db_service_names :
    service_name => {
      db_name           = "${service_name}_db"
      username          = lower("${service_name}_user")
      allocated_storage = 50
      iops              = 1000
      aries_db          = var.aries_db
      platform_db       = var.platform_db
      db_sg_id          = lookup(var.db_sg_ids, service_name, null)
      rds_proxy_sg_ids  = lookup(var.rds_proxy_sg_ids, service_name, null)
    }
  }
}
