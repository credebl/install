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
   "user-service",
    "api-gateway-service",
    "organization-service",
    "agent-provisioning-service",
    "agent-service",
    "verification-service",
    "ledger-service",
    "issuance-service",
    "connection-service",
    "CREDENTAILDEFINITION_SERVICE_3",
    "schema-file-server-service",
    "webhook-service",
    "utility-service",
    "notification-service",
    "geolocation-service",
    "cloud-wallet-service",
  ]
}

