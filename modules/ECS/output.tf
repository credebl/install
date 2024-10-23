

output "withoutport_taskdefinition_arns" {
  description = "The ARNs of the ECS task definitions"
  value       = { for td in aws_ecs_task_definition.withoutport_task_definition : td.family => td.arn }
}

output "withport_taskdefinition_arn" {
  description = "The ARNs of the ECS task definitions"
  value       = { for td in aws_ecs_task_definition.withport_task_definition : td.family => td.arn }
}

output "schemafile-server_taskdefinition_arn" {
  value = aws_ecs_task_definition.schema_task_definition.arn
}

output "agent_provisioning_taskdefinition_arn" {
  value = aws_ecs_task_definition.agent_provisioning_task_definition.arn
}

# Output the DNS names of the ALBs
output "alb_dns_names" {
  value       = { for alb in aws_lb.alb : alb.name => alb.dns_name }
  description = "Map of ALB names to their DNS names"
}

# Output the ARNs of the ALBs
output "alb_arns" {
  value       = { for alb in aws_lb.alb : alb.name => alb.arn }
  description = "Map of ALB names to their ARNs"
}


# Output the ARNs of the target groups as a list
output "target_group_arns" {
  value       = [for tg in aws_lb_target_group.tg : tg.arn]
  description = "List of target group ARNs"
}
