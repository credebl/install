locals {

  api_gateway_service_connect = "${lower(var.SERVICE_CONFIG.WITH_PORT[0].SERVICE_NAME)}-sc.${lower(replace("${var.environment}-${var.project_name}-namespace", "_", "-"))}:${var.SERVICE_CONFIG.WITH_PORT[0].PORT}"
  redis_service_connect       = "http://${lower(var.REDIS_CONFIG.SERVICE_NAME)}-sc.${lower(replace("${var.environment}-${var.project_name}-namespace", "_", "-"))}:${var.REDIS_CONFIG.PORT}"
  keyclock_service_connect    = "http://${lower(var.SERVICE_CONFIG.WITH_PORT[1].SERVICE_NAME)}-sc.${lower(replace("${var.environment}-${var.project_name}-namespace", "_", "-"))}:${var.SERVICE_CONFIG.WITH_PORT[1].PORT}"
  schema_file_service_connect = "http://${lower(var.SCHEMA_FILE_SERVICE_CONFIG.SERVICE_NAME)}-sc.${lower(replace("${var.environment}-${var.project_name}-namespace", "_", "-"))}:${var.SERVICE_CONFIG.WITH_PORT[1].PORT}"
  webauthn_service_connect    = "http://${lower(var.SERVICE_CONFIG.WITH_PORT[3].SERVICE_NAME)}-sc.${lower(replace("${var.environment}-${var.project_name}-namespace", "_", "-"))}:${var.SERVICE_CONFIG.WITH_PORT[1].PORT}"
}

locals {
  api_gateway_db_credentials = var.database_info_by_service["api_gateway"]
  keycloak_db_credentials    = var.database_info_by_service["keycloak"]
  mediator_db_credentials    = var.database_info_by_service["mediator"]
}

locals {
  api_gateway_rds_proxy_credentials = var.rds_proxy_info_by_service["api_gateway"]
  keycloak_rds_proxy_credentials    = var.rds_proxy_info_by_service["keycloak"]
  mediator_rds_proxy_credentials    = var.rds_proxy_info_by_service["mediator"]
}

locals {
  alb_dns_by_service = {
    for service_name, alb_dns in var.alb_dns_by_service : service_name => alb_dns
  }
}
