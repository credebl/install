
resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment}-${var.cluster_name}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_service" "withoutport_service" {
  for_each        = toset(var.service_names) # Assuming `service_names` is a list of service names
  name            = each.value
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.withoutport_task_definition[each.value].arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_service_desired_count

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.platform_sg_id]
    assign_public_ip = true
  }
  depends_on = [aws_ecs_cluster.cluster, aws_ecs_task_definition.withoutport_task_definition, aws_ecs_service.agent_provisioning_service]

}

resource "aws_ecs_service" "agent_provisioning_service" {
  # Assuming `service_names` is a list of service names
  name            = "AGENT_PROVISIONING_SERVICE"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.agent_provisioning_task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_service_desired_count

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.platform_sg_id]
    assign_public_ip = true
  }
  depends_on = [aws_ecs_cluster.cluster, aws_ecs_task_definition.agent_provisioning_task_definition]

}



resource "aws_ecs_service" "schema_service" {
  # Assuming `service_names` is a list of service names
  name            = "SCHEMAFILE_SERVER_SERVICE"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.schema_task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_service_desired_count

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.platform_sg_id]
    assign_public_ip = true
  }
  depends_on = [aws_ecs_cluster.cluster, aws_ecs_task_definition.schema_task_definition]

}

resource "aws_ecs_service" "withport_service" {
  for_each        = { for i, service in var.service_configs : service.env_file_suffix => service } # Assuming `service_names` is a list of service names
  name            = each.value.name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.withport_task_definition[each.value.name].arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_service_desired_count

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [for k in local.service_sg_groups : k]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg[each.key].arn
    container_name   = each.value.name
    container_port   = each.value.port
  }
  depends_on = [aws_ecs_cluster.cluster, aws_ecs_task_definition.withoutport_task_definition, aws_ecs_service.agent_provisioning_service, aws_lb.alb,aws_lb_target_group.tg]

}
