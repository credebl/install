locals {
  alb_sg_group = [var.platform_alb_sg_id, var.mediator_alb_sg_id, var.keycloak_alb_sg_id]
}

locals {
  service_sg_groups = [var.platform_sg_id, var.mediator_sg_id, var.keycloak_sg_id]
}


locals {
  # Extract names from service_configs
  service_configs_names = [for config in var.service_configs : config.name]

  # Combine service names from multiple sources
  autoscale_services = concat(
    var.service_names,
    local.service_configs_names,
    ["AGENT_PROVISIONING_SERVICE", "SCHEMAFILE_SERVER_SERVICE"]
  )
}

# locals {
#   task_definition_arn = concat(
#     aws_ecs_task_definition.withport_task_definition[*],

#   )
# }