output "alb_security_group_ids" {
  description = "Security Group IDs for each service ALB"
  value       = { for key, sg in aws_security_group.ALB_SG : key => sg.id }
}

output "app_security_group_ids" {
  description = "Security Group IDs for each application"
  value       = { for key, sg in aws_security_group.APP_SG : key => sg.id }
}

output "nats_count" {
  value = length(aws_security_group.NATS_SG)
}

output "nats_security_group_ids" {
  description = "Security Group IDs for NATS services"
  value       = { for idx, sg in aws_security_group.NATS_SG : sg.name => sg.id }
  sensitive   = true
}

output "nats_alb_security_group_ids" {
  value     = { for idx, sg in aws_security_group.NATS_ALB_SG : sg.name => sg.id }
  sensitive = true
}

output "SERVICE_CONFIG" {
  description = "service data"
  value       = var.SERVICE_CONFIG
}


output "efs_sg_id" {
  value = aws_security_group.EFS_SG.id
}

output "AGENT_PROVISIONING_SERVICE" {
  value = var.AGENT_PROVISIONING_SERVICE
}

output "redis_sg_id" {
  value = aws_security_group.REDIS_SG.id
}

output "REDIS_CONFIG" {
  value = local.REDIS_CONFIG
}


