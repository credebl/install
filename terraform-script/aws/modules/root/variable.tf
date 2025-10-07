# aws credentials
variable "profile" {}
variable "project_name" {}
variable "environment" {}
variable "crypto_private_key" {}
# vpc credentials
variable "region" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {
  type = list(string)
}
variable "private_app_subnet_cidr" {
  type = list(string)
}

variable "private_db_subnet_cidr" {
  type = list(string)
}

variable "SENDGRID_API_KEY" {}
variable "AWS_ACCOUNT_ID" {}


# Security Group
# ALB security group ports
variable "ALB_SG" {
  type    = list(number)
  default = [80, 443]
}



variable "SERVICE_CONFIG" {
  type = object({
    WITH_PORT = list(object({
      SERVICE_NAME   = string
      PORT           = number
      DB_PORT        = number
      file_system_id = string
      container_cmd  = string
      health_check = object({
        path                = string
        interval            = number
        timeout             = number
        healthy_threshold   = number
        unhealthy_threshold = number
        matcher             = string
      })
    }))

    WITHOUT_PORT = list(string)

    NATS = object({
      SERVICE_NAME = string
      PORT         = list(number)

    })
  })

  default = {
    WITH_PORT = [
      {
        SERVICE_NAME   = "api-gateway"
        PORT           = 5000
        DB_PORT        = 5432
        container_cmd  = ""
        file_system_id = ""
        health_check = {
          path                = "/api"
          interval            = 30
          timeout             = 5
          healthy_threshold   = 3
          unhealthy_threshold = 2
          matcher             = "200"
        }
      },
      {
        SERVICE_NAME   = "keycloak"
        PORT           = 8080
        DB_PORT        = 5432
        container_cmd  = "start"
        file_system_id = ""
        health_check = {
          path                = "/documentation.html"
          interval            = 300
          timeout             = 120
          healthy_threshold   = 5
          unhealthy_threshold = 2
          matcher             = "200,404"
        }
      },
      {
        SERVICE_NAME   = "mediator"
        PORT           = 3000
        DB_PORT        = 5432
        container_cmd  = ""
        file_system_id = ""
        health_check = {
          path                = "/health"
          interval            = 300
          timeout             = 120
          healthy_threshold   = 5
          unhealthy_threshold = 2
          matcher             = "200,404,201"
        }
      },
      {
        SERVICE_NAME   = "webauthn"
        PORT           = 8000
        DB_PORT        = null # Placeholder for services without DB_PORT
        container_cmd  = ""
        file_system_id = ""
        health_check = {
          path                = "/"
          interval            = 300
          timeout             = 120
          healthy_threshold   = 5
          unhealthy_threshold = 2
          matcher             = "200,404"
        }
      },
      {
        SERVICE_NAME   = "ui"
        PORT           = 8085
        DB_PORT        = null # Placeholder for services without DB_PORT
        container_cmd  = ""
        file_system_id = ""
        health_check = {
          path                = "/"
          interval            = 300
          timeout             = 120
          healthy_threshold   = 5
          unhealthy_threshold = 2
          matcher             = "200,404"
        }
      }
    ]

    WITHOUT_PORT = [
      "utility",
      "verification",
      "webhook",
      "organization",
      "connection",
      "issuance",
      "user",
      "notification",
      "ledger",
      "geolocation",
      "cloud-wallet",
      "agent-service"
    ]

    NATS = {
      SERVICE_NAME = "nats"
      PORT         = [4222, 8222, 443, 4245]
    }
  }
}

variable "SCHEMA_FILE_SERVICE_CONFIG" {
  type = object({
    SERVICE_NAME = string
    PORT         = number
    health_check = object({
      path                = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
      matcher             = string # Add matcher here as well
    })
  })

  default = {
    SERVICE_NAME = "schema-file-server"
    PORT         = 8000
    health_check = {
      path                = "/health"
      interval            = 300
      timeout             = 120
      healthy_threshold   = 5
      unhealthy_threshold = 2
      matcher             = "200,404" # Ensure matcher is defined
    }
  }
}



variable "AGENT_PROVISIONING_SERVICE" {
  type = object({
    SERVICE_NAME = string
  })

  default = {
    SERVICE_NAME = "agent-provisioning"
  }
}

variable "PLATFORM_WALLET_PASSWORD" {}
variable "aries_db" {
  type    = string
  default = "db.t4g.small"
}
variable "platform_db" {
  type    = string
  default = "db.t4g.small"
}

variable "platform_seed" {}
