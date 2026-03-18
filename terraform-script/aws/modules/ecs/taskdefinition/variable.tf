variable "environment" {}
variable "project_name" {}
variable "vpc_id" {}
variable "alb_security_group_ids" {}
variable "SERVICE_CONFIG" {}
variable "app_security_group_ids" {
  type = map(string)
}
variable "public_subnet_ids" {}
variable "env_file_bucket_arn" {}
variable "ecs_tasks_execution_role_arn" {}
variable "ecs_tasks_role_arn" {}
variable "log_groups_nats" {}
variable "log_groups_without_port" {}
variable "log_groups_with_port" {}
variable "region" {}
variable "credo_efs_id" {}
variable "nats_efs_id" {}

variable "AGENT_PROVISIONING_SERVICE" {}
variable "log_groups_agent_provisioning_service" {}
variable "REDIS_CONFIG" {}
variable "credo_port" {}
variable "credo_inbound_port" {}
variable "nats_efs_access_point_id" {}
variable "natscluster" {
  default = true
}
variable "image_url" {}
variable "domain_name" {
  description = "Domain name for Keycloak hostname configuration"
  type        = string
}
variable "rds_endpoint" {
  description = "RDS endpoint for database connection"
  type        = string
  sensitive   = true
}
variable "rds_port" {
  description = "RDS port for database connection"
  type        = number
  sensitive   = true
}
variable "db_secret_arn" {
  description = "ARN of the secret containing database credentials"
  type        = string
}