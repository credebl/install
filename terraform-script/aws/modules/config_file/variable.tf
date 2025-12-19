variable "SERVICE_CONFIG" {}
variable "AGENT_PROVISIONING_SERVICE" {}
variable "REDIS_CONFIG" {}
variable "environment" {}
variable "project_name" {}

variable "env_file_bucket_arn" {}
variable "link_bucket_id" {}
variable "org_logo_bucket_id" {}
variable "org_logo_bucket_dns" {}
variable "database_info_by_service" {}
# variable "rds_proxy_info_by_service" {}


variable "alb_dns_by_service" {}
variable "env_file_bucket_id" {}
variable "region" {}
variable "alb_details" {}
variable "domain_name" {}
variable "AWS_ACCOUNT_ID" {}
locals {
  services = [
    "USER_SERVICE",
    "API_GATEWAY_SERVICE",
    "ORGANIZATION_SERVICE",
    "AGENT_PROVISIONING_SERVICE",
    "AGENT_SERVICE_SERVICE",
    "VERIFICATION_SERVICE",
    "LEDGER_SERVICE",
    "ISSUANCE_SERVICE",
    "CONNECTION_SERVICE",
    "ECOSYSTEM_SERVICE",
    "CREDENTAILDEFINITION_SERVICE",
    "SCHEMA_SERVICE",
    "WEBHOOK_SERVICE",
    "UTILITIES_SERVICE",
    "NOTIFICATION_SERVICE",
    "GEOLOCATION_SERVICE",
    "CLOUD_WALLET_SERVICE"
  ]
}