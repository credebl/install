# aws credentials
variable "profile" {}
variable "project_name" {}
variable "environment" {}
variable "region" {}


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
          interval            = 61
          timeout             = 60
          healthy_threshold   = 5
          unhealthy_threshold = 3
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
        SERVICE_NAME   = "ui"
        PORT           = 3000
        DB_PORT        = null
        container_cmd  = ""
        file_system_id = ""
        health_check = {
          path                = "/auth/sign-in"
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
      "agent-service",
      "oid4vc-issuance",
      "oid4vp-verification"
    ]

    NATS = {
      SERVICE_NAME = "nats"
      PORT         = [4222, 8222, 443]
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

variable "credo_port" {
  default = 8001
}
variable "credo_inbound_port" {
  default = 9001
}
