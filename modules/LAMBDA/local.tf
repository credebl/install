locals {
  cluster_count = var.nats_count
  cluster_ips = [
    for i in range(local.cluster_count) : format(
      "nats://nats-%d-%d.%s-namespace:%d",
      i + 1,
      var.SERVICE_CONFIG.NATS.PORT[3],                                    # Index for each NATS instance (7, 2, ...)
      lower(replace("${var.environment}-${var.project_name}", "_", "-")), # Cluster name with "_" replaced by "-"
      var.SERVICE_CONFIG.NATS.PORT[3]                                     # The desired port from the service config
    )
  ]
}

locals {
  services = [
   "USER_SERVICE_30",
    "API_GATEWAY_SERVICE_30",
    "ORGANIZATION_SERVICE_30",
    "AGENT_PROVISIONING_SERVICE_30",
    "AGENT_SERVICE_30_SERVICE_30",
    "VERIFICATION_SERVICE_30",
    "LEDGER_SERVICE_30",
    "ISSUANCE_SERVICE_30",
    "CONNECTION_SERVICE_30",
    "ECOSYSTEM_SERVICE_30",
    "CREDENTAILDEFINITION_SERVICE_30",
    "SCHEMA_SERVICE_30",
    "WEBHOOK_SERVICE_30",
    "UTILITIES_SERVICE_30",
    "NOTIFICATION_SERVICE_30",
    "GEOLOCATION_SERVICE_30",
    "CLOUD_WALLET_SERVICE_30"
  ]
}

