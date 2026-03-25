output "with_port_task_definitions" {
  value = {
    for service, task_def in aws_ecs_task_definition.with_port_task_definitions :
    service => task_def.arn
  }

}

output "without_port_task_definitions" {
  value = {
    for service, task_def in aws_ecs_task_definition.without_port_task_definitions :
    service => task_def.arn
  }
  description = "The ARNs of ECS task definitions without ports"
}

output "agent_provisioning_service_task_definition" {
  value = aws_ecs_task_definition.agent_provisioning_service_task_definitions.arn
  description = "The ARN of the agent provisioning service ECS task definition"
}

output "nats_service_task_definitions" {
  value = [
    for task in aws_ecs_task_definition.nats_service_task_definitions : task.arn
  ]
  description = "The ARNs of NATS service ECS task definitions"
}

output "redis_server_task_definitions_arn" {
  value = aws_ecs_task_definition.redis_server_task_definitions.arn
}

output "seed_task_definition_arn" {
  value = aws_ecs_task_definition.seed_taskdefinition.arn
}