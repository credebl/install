resource "aws_ecs_task_definition" "with_port_task_definitions" {
  for_each               = { for idx, service in var.SERVICE_CONFIG.WITH_PORT : service.SERVICE_NAME => service }
  family                 = upper("${var.project_name}_${var.environment}_${each.value.SERVICE_NAME}_TASKDEFINITION")
  network_mode           = "awsvpc"
  cpu                    = "512"
  memory                 = "1024"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn     = var.ecs_tasks_execution_role_arn
  task_role_arn          = var.ecs_tasks_role_arn

  container_definitions = jsonencode([
    {
      name      = each.value.SERVICE_NAME
      image     = lower(each.value.SERVICE_NAME == "keycloak" ? "quay.io/keycloak/keycloak:25.0.6" : "${var.image_url}:${each.value.SERVICE_NAME}")
      cpu       = 512
      memory    = 1024
      essential = true

      command   = each.value.SERVICE_NAME == "keycloak" ? ["start"] : null

      environmentFiles = [
        {
          value = "${var.env_file_bucket_arn}/${var.environment}-${each.value.SERVICE_NAME == "api-gateway" ? "credebl" : each.value.SERVICE_NAME}.env"
          type  = "s3"
        }
      ]

      environment = each.value.SERVICE_NAME == "keycloak" ? [
        {
          name  = "KC_HOSTNAME_ADMIN_URL"
          value = "https://${var.environment == "prod" ? "keycloak" : "${var.environment}-keycloak"}.${var.domain_name}/"
        },
        {
          name  = "KC_HOSTNAME_URL"
          value = "https://${var.environment == "prod" ? "keycloak" : "${var.environment}-keycloak"}.${var.domain_name}/"
        },
        {
          name  = "KC_DB_URL"
          value = "jdbc:postgresql://${var.rds_endpoint}:${var.rds_port}/keycloak"
        },
        {
          name  = "KC_DB_USERNAME"
          value = "keycloak_user"
        }
      ] : []

      secrets = each.value.SERVICE_NAME == "keycloak" ? [
        {
          name      = "KC_DB_PASSWORD"
          valueFrom = "${var.db_secret_arn}:keycloak_password::"
        }
      ] : each.value.SERVICE_NAME == "api-gateway" ? [
        {
          name      = "DATABASE_URL"
          valueFrom = "${var.db_secret_arn}:credebl_url::"
        },
        {
          name      = "POOL_DATABASE_URL"
          valueFrom = "${var.db_secret_arn}:credebl_url::"
        }
      ] : []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}_${var.environment}_${each.value.SERVICE_NAME}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = "ARM64"
        operatingSystemFamily = "LINUX"
      }
    
      portMappings = [
        {
          containerPort = each.value.PORT # Replace with your UI's port
          hostPort      = each.value.PORT
          protocol      = "tcp",
          name          = lower("${each.value.SERVICE_NAME}-${each.value.PORT}-tcp")
          appProtocol   = "http"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "without_port_task_definitions" {
  for_each               = toset(local.SERVICE_CONFIG.WITHOUT_PORT)
  family                 = upper("${var.project_name}_${var.environment}_${each.value}_TASKDEFINITION")
  network_mode           = "awsvpc"
  cpu                    = "512"
  memory                 = "1024"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn     = var.ecs_tasks_execution_role_arn
  task_role_arn          = var.ecs_tasks_role_arn

  container_definitions = jsonencode([
    {
      name      = each.value
      image     = lower("${var.image_url}:${each.value}")
      cpu       = 512
      memory    = 1024
      essential = true

      environmentFiles = [
        {
          value = "${var.env_file_bucket_arn}/${var.environment}-credebl.env"
          type  = "s3"
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = "${var.db_secret_arn}:credebl_url::"
        },
        {
          name      = "POOL_DATABASE_URL"
          valueFrom = "${var.db_secret_arn}:credebl_url::"
        }
      ]

      # Conditional mount points for agent-service
      mountPoints = each.value == "agent-service" ? [
        {
          containerPath = "/app/agent-provisioning/AFJ/token"
          readOnly      = false
          sourceVolume  = "agent-token"
        }
      ] : []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}_${var.environment}_${each.value}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = "ARM64"
        operatingSystemFamily = "LINUX"
      }
    }
  ])
  dynamic "volume" {
    for_each = each.value == "agent-service" ? [1] : []

    content {
      name = "agent-token"
      efs_volume_configuration {
        file_system_id = var.credo_efs_id
        root_directory = "/token"
      }
    }
  }
}

resource "aws_ecs_task_definition" "agent_provisioning_service_task_definitions" {
  family                 = upper("${var.project_name}_${var.environment}_${var.AGENT_PROVISIONING_SERVICE.SERVICE_NAME}_TASKDEFINITION")
  network_mode           = "awsvpc"
  cpu                    = "512"
  memory                 = "1024"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn     = var.ecs_tasks_execution_role_arn
  task_role_arn          = var.ecs_tasks_role_arn

  container_definitions = jsonencode([
    {
      name      = var.AGENT_PROVISIONING_SERVICE.SERVICE_NAME
      image     = lower("${var.image_url}:${var.AGENT_PROVISIONING_SERVICE.SERVICE_NAME}")
      cpu       = 512
      memory    = 1024
      essential = true

      environmentFiles = [
        {
          value = "${var.env_file_bucket_arn}/${var.environment}-credebl.env"
          type  = "s3"
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = "${var.db_secret_arn}:credebl_url::"
        },
        {
          name      = "POOL_DATABASE_URL"
          valueFrom = "${var.db_secret_arn}:credebl_url::"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "agent-config"
          containerPath = "/app/agent-provisioning/AFJ/agent-config"
          readOnly      = false
        },
        {
          containerPath = "/app/agent-provisioning/AFJ/token"
          sourceVolume  = "agent-token"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}_${var.environment}_${var.AGENT_PROVISIONING_SERVICE.SERVICE_NAME}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = "ARM64"
        operatingSystemFamily = "LINUX"
      }
    }
  ])
  volume {
    name = "agent-config"
    efs_volume_configuration {
      file_system_id = var.credo_efs_id
      root_directory = "/"
    }
  }
  volume {
    name = "agent-token"
    efs_volume_configuration {
      file_system_id = var.credo_efs_id
      root_directory = "/token"
    }
  }

}

resource "aws_ecs_task_definition" "nats_service_task_definitions" {
  count                    = lower(var.environment) == "prod"  || var.natscluster == true  ? 3 : 1
  family                   = upper("${var.project_name}_${var.environment}_${var.SERVICE_CONFIG.NATS.SERVICE_NAME}_${count.index+1}_TASKDEFINITION")
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_tasks_execution_role_arn
  task_role_arn            = var.ecs_tasks_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.SERVICE_CONFIG.NATS.SERVICE_NAME}_${count.index+1}"
      image     = "nats:2.6.4"
      cpu       = 512
      memory    = 1024
      essential = true
      command   = [
                "-c",
                "/config/nats_${count.index+1}.config"
            ]
      environmentFiles = []

      mountPoints = [
        {
          sourceVolume  = "nats-config"
          containerPath = "/config"
          readOnly      = false
        }
      ]

      # Dynamically creating portMappings with incremented ports based on count.index
      portMappings = [
        {
          containerPort = 4222 + count.index
          hostPort      = 4222 + count.index
          protocol      = "tcp",
          name          = lower("${var.SERVICE_CONFIG.NATS.SERVICE_NAME}-${count.index+1}-${4222 + count.index}-tcp")
        },
        {
          containerPort = 6222 + count.index
          hostPort      = 6222 + count.index
          protocol      = "tcp",
          name          = lower("${var.SERVICE_CONFIG.NATS.SERVICE_NAME}-${count.index+1}-${6222 + count.index}-tcp")
        },
        {
          containerPort = 8222 + count.index
          hostPort      = 8222 + count.index
          protocol      = "tcp",
          name          = lower("${var.SERVICE_CONFIG.NATS.SERVICE_NAME}-${count.index+1}-${8222 + count.index}-tcp")
        },
        {
          containerPort = 7422 + count.index
          hostPort      = 7422 + count.index
          protocol      = "tcp",
          name          = lower("${var.SERVICE_CONFIG.NATS.SERVICE_NAME}-${count.index+1}-${7422 + count.index}-tcp")
        },
        {
          containerPort = 8442 + count.index
          hostPort      = 8442 + count.index
          protocol      = "tcp",
          name          = lower("${var.SERVICE_CONFIG.NATS.SERVICE_NAME}-${count.index+1}-${8442 + count.index}-tcp")
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}_${var.environment}_${var.SERVICE_CONFIG.NATS.SERVICE_NAME}_${count.index+1}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = "ARM64"
        operatingSystemFamily = "LINUX"
      }
      
    }
  ])

  volume {
    name = "nats-config"
    efs_volume_configuration {
      file_system_id = var.nats_efs_id
      root_directory = "/"
    }
  }
}


resource "aws_ecs_task_definition" "redis_server_task_definitions" {
  family                   = upper("${var.project_name}_${var.environment}_${var.REDIS_CONFIG.SERVICE_NAME}_TASKDEFINITION")
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_tasks_execution_role_arn
  task_role_arn            = var.ecs_tasks_role_arn

  container_definitions = jsonencode([
    {
      name      = var.REDIS_CONFIG.SERVICE_NAME
      image     = "redis"
      cpu       = 512
      memory    = 1024
      essential = true
      environmentFiles = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}_${var.environment}_${var.REDIS_CONFIG.SERVICE_NAME}"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = "ARM64"
        operatingSystemFamily = "LINUX"
      }
    
      command = [
        "redis-server",
        "--save", "20", "1",
        "--loglevel", "warning"
      ]

      portMappings = [
        {
          containerPort = var.REDIS_CONFIG.PORT
          hostPort      = var.REDIS_CONFIG.PORT
          protocol      = "tcp",
          name          = lower("${var.REDIS_CONFIG.SERVICE_NAME}-${var.REDIS_CONFIG.PORT}-tcp")
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "credo_taskdefinition" {
  family                   = upper("${var.project_name}_${var.environment}_credo_TASKDEFINITION")
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_tasks_execution_role_arn
  task_role_arn            = var.ecs_tasks_role_arn

  container_definitions = jsonencode([
    {
      name      = "credo"
      image     = "${var.image_url}:credo-controller"
      cpu       = 1024
      memory    = 2048
      essential = true

      environmentFiles = [
        {
          value = "${var.env_file_bucket_arn}/${var.environment}-credo.env"
          type  = "s3"
        }
      ]
      
      mountPoints = [
        {
          sourceVolume  = "config"
          containerPath = "/config"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}_${var.environment}_credo"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
      command = ["--auto-accept-connections", "--config", "/config/config.json"]
      portMappings = [
        {
          containerPort = var.credo_port
          hostPort      = var.credo_port
          protocol      = "tcp",
        },
        {
          containerPort = var.credo_inbound_port
          hostPort      = var.credo_inbound_port
          protocol      = "tcp",
        }
      ]

      runtime_platform = {
        cpuArchitecture       = "ARM64"
        operatingSystemFamily = "LINUX"
      }
    }
  ])

  volume {
    name = "config"
    efs_volume_configuration {
      file_system_id = var.credo_efs_id
      root_directory = "/"
    }
  }

}

resource "aws_ecs_task_definition" "seed_taskdefinition" {
  family                   = upper("${var.project_name}_${var.environment}_seed_TASKDEFINITION")
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_tasks_execution_role_arn
  task_role_arn            = var.ecs_tasks_role_arn

  container_definitions = jsonencode([
    {
      name      = "seed"
      image     = "${var.image_url}:seed"
      cpu       = 256
      memory    = 512
      essential = true
      
      environmentFiles = [
        {
          value = "${var.env_file_bucket_arn}/${var.environment}-credebl.env"
          type  = "s3"
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = "${var.db_secret_arn}:credebl_url::"
        },
        {
          name      = "POOL_DATABASE_URL"
          valueFrom = "${var.db_secret_arn}:credebl_url::"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "seed-data"
          containerPath = "/app/libs/prisma-service/prisma/data"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}_${var.environment}_seed"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }

      runtime_platform = {
        cpuArchitecture       = "ARM64"
        operatingSystemFamily = "LINUX"
      }
    }
  ])

  volume {
    name = "seed-data"
    efs_volume_configuration {
      file_system_id = var.nats_efs_id
      authorization_config {
      access_point_id = var.nats_efs_access_point_id
      iam             = "DISABLED"
    }
      transit_encryption = "ENABLED"
    }
  }

}
