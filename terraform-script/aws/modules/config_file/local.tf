locals {
  api_gateway_db_credentials = var.database_info_by_service["api-gateway"]
  keycloak_db_credentials    = var.database_info_by_service["keycloak"]
  mediator_db_credentials    = var.database_info_by_service["mediator"]
}

locals {
  api_gateway_rds_proxy_credentials = var.rds_proxy_info_by_service["api-gateway"]
  keycloak_rds_proxy_credentials    = var.rds_proxy_info_by_service["keycloak"]
  mediator_rds_proxy_credentials    = var.rds_proxy_info_by_service["mediator"]
}