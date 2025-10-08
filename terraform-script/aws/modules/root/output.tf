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

output "vpc_cidr" {
  description = "The CIDR block for the VPC"
  value       = var.vpc_cidr
}

output "public_subnet_cidr" {
  description = "The CIDR blocks for the public subnets"
  value       = var.public_subnet_cidr
}

output "private_app_subnet_cidr" {
  description = "The CIDR blocks for the private application subnets"
  value       = var.private_app_subnet_cidr
}

output "private_db_subnet_cidr" {
  description = "The CIDR blocks for the private database subnets"
  value       = var.private_db_subnet_cidr
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