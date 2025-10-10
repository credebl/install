output "profile" {
  description = "The AWS profile being used"
  value       = var.profile
}

output "project_name" {
  description = "The name of the project"
  value       = var.project_name
}

output "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  value       = var.environment
}

output "region" {
  description = "The AWS region where the resources are deployed"
  value       = var.region
}

output "SERVICE_CONFIG" {
  value = var.SERVICE_CONFIG
}

output "AGENT_PROVISIONING_SERVICE" {
  value = var.AGENT_PROVISIONING_SERVICE
}

output "ALB_SG" {
  value = var.ALB_SG
}

output "credo_port" {
  value = var.credo_port
}

output "credo_inbound_port" {
  value = var.credo_inbound_port
}