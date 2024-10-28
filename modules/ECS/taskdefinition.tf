resource "aws_ecs_task_definition" "withoutport_task_definition" {
  for_each = toset(var.service_names)

  family                   = "${each.value}_TASKDEFINITION"
  network_mode             = "awsvpc"
  cpu                      = var.cpu_units    # Convert to number
  memory                   = var.memory_units # Convert to number
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_tasks_execution_role_arn
  task_role_arn            = var.ecs_tasks_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = each.value
      image     = "${var.repo_url}:${each.value}" # Correctly reference the image
      cpu       = tonumber(var.cpu_units)              # Convert to number
      memory    = tonumber(var.memory_units)           # Convert to number
      essential = true

      environmentFiles = [
        {
          value = "${var.env_file_bucket_arn}/${var.environment}-platform.env"
          type  = "s3"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_groups_without_port[each.value].name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = var.cpuArchitecture
        operatingSystemFamily = "LINUX"
      }
    }
  ])
}

# services which required port
resource "aws_ecs_task_definition" "withport_task_definition" {
  for_each = { for i, service in var.service_configs : service.name => service }

  family                   = "${each.key}_TASKDEFINITION"
  network_mode             = "awsvpc"
  cpu                      = var.cpu_units
  memory                   = var.memory_units
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_tasks_execution_role_arn
  task_role_arn            = var.ecs_tasks_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = "${var.repo_url}:${each.key}"
      cpu       = tonumber(var.cpu_units)
      memory    = tonumber(var.memory_units)
      essential = true
      command = [
            "each.value.container_cmd",
      ]
      environmentFiles = [
        {
          value = "${var.env_file_bucket_arn}/${var.environment}-${each.value.env_file_suffix}.env",
          type  = "s3"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_groups_with_port[each.value.name].name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = var.cpuArchitecture
        operatingSystemFamily = "LINUX"
      }

      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]
    }
  ])
}


resource "aws_ecs_task_definition" "schema_task_definition" {
  family                   = "SCHEMAFILE_SERVER_SERVICE_TASKDEFINITION"
  network_mode             = "awsvpc"
  cpu                      = tonumber(var.cpu_units)
  memory                   = tonumber(var.memory_units)
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_tasks_execution_role_arn
  task_role_arn            = var.ecs_tasks_execution_role_arn


  container_definitions = jsonencode([
    {
      name      = "SCHEMAFILE_SERVER_SERVICE"
      image     = "public.ecr.aws/ayanworks-technologies/credebl:NOTIFICATION_WEBHOOK_Service"
      cpu       = tonumber(var.cpu_units)
      memory    = tonumber(var.memory_units)
      essential = true

      environmentFiles = [
        {
          value = "${var.env_file_bucket_arn}/${var.environment}-schema.env"
          type  = "s3"
        }
      ]

      mountPoints = [
        {
          "sourceVolume" : "schemafile",
          "containerPath" : "/app/agent-provisioning/AFJ/agent-config",
          "readOnly" : false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}_SCHEMAFILE_SERVER_SERVICE_LOGS"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = var.cpuArchitecture
        operatingSystemFamily = "LINUX"
      }
      portMappings = [
        {
          containerPort = var.SCHEMAFILE_SERVER_SERVICE_PORT
          hostPort      = var.SCHEMAFILE_SERVER_SERVICE_PORT
          protocol      = "tcp"
        }
      ]
    }
  ])
  volume {
    name = "schemafile"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = lookup(var.access_point_details, "/schema", "")
        iam             = "DISABLED"
      }
    }
  }

}



# ....................................................................................
resource "aws_ecs_task_definition" "agent_provisioning_task_definition" {
  family                   = "AGENT_PROVISIONING_SERVICE_TASKDEFINITION"
  network_mode             = "awsvpc"
  cpu                      = tonumber(var.cpu_units)
  memory                   = tonumber(var.memory_units)
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_tasks_execution_role_arn
  task_role_arn = var.ecs_tasks_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "AGENT_PROVISIONING_SERVICE"
      image     = "${var.repo_url}:AGENT_PROVISIONING_SERVICE"
      cpu       = tonumber(var.cpu_units)
      memory    = tonumber(var.memory_units)
      essential = true

      environmentFiles = [
        {
          value = "${var.env_file_bucket_arn}/${var.environment}-platform.env"
          type  = "s3"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "agent-config"
          containerPath = "/app/agent-provisioning/AFJ/agent-config"
          readOnly      = false
        },
        {
          sourceVolume  = "port-file"
          containerPath = "/app/agent-provisioning/AFJ/port-config"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}_AGENT_PROVISIONING_SERVICE_LOGS"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = var.cpuArchitecture
        operatingSystemFamily = "LINUX"
      }
    }
  ])

  volume {
    name = "agent-config"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = lookup(var.access_point_details, "/agent-config", "")
        iam             = "DISABLED"
      }
    }
  }

  volume {
    name = "port-file"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = lookup(var.access_point_details, "/port-file", "")
        iam             = "DISABLED"
      }
    }
  }
}
