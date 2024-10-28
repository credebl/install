variable "project_name" {}
variable "region" {}
variable "repo_url" {}
variable "ecs_tasks_execution_role_arn" {}
variable "env_file_bucket_arn" {}
variable "environment" {}
variable "vpc_id" {}
variable "mediator_alb_sg_id" {}
variable "platform_alb_sg_id" {}
variable "keycloak_alb_sg_id" {}
variable "platform_sg_id" {}
variable "mediator_sg_id" {}
variable "keycloak_sg_id" {}
variable "nats_instance_public_ips" {}
variable "efs_id" {}
variable "platform_database_name" {}

variable "cpu_units" {
  type = string
}
variable "memory_units" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "service_names" {
  type    = list(string)
  default = ["ISSUANCE_SERVICE","CONNECTION_SERVICE", "LEDGER_SERVICE", "AGENT_SERVICE", "ORGNIZATION_SERVICE", "GEOLOCATION_SERVICE", "NOTIFICATION_SERVICE", "USER_SERVICE", "UTILITY_SERVICE", "VERIFICATION_SERVICE"]
}

variable "cpuArchitecture" {
  type = string
}

# Variable definition for service configurations
variable "service_configs" {
  description = "List of service configurations including ports, env_file_suffix, and health check details."
  type = list(object({
    name            = string
    port            = number
    env_file_suffix = string
    image_url = string
    container_cmd = string
    health_check = object({
      path                = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
      
    })
  }))
  default = [
    {
      name            = "API-GATEWAY-SERVICE"
      port            = 5000
      env_file_suffix = "platform"
      image_url = "public.ecr.aws/ayanworks-technologies/credebl:API_GATEWAY_Service"
      container_cmd = ""
      health_check = {
        path                = "/api"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 2
      }
    },
    {
      name            = "MEDIATOR_SERVICE"
      port            = 3000
      env_file_suffix = "mediator"
      image_url = "public.ecr.aws/ayanworks-technologies/credebl:MEDIATOR_Service"
      container_cmd = ""
      health_check = {
        path                = "/health"
        interval            = 300
        timeout             = 120
        healthy_threshold   = 5
        unhealthy_threshold = 2
      }
    },
    {
      name            = "KEYCLOAK_SERVICE"
      port            = 8080
      env_file_suffix = "keycloak"
      image_url = "quay.io/keycloak/keycloak:25.0.6"
      container_cmd = "start"
      health_check = {
        path                = "/documentation.html"
        interval            = 300
        timeout             = 120
        healthy_threshold   = 5
        unhealthy_threshold = 2
      }
    }
  ]
}

variable "SCHEMAFILE_SERVER_SERVICE_PORT" {
  type    = number
  default = 3000
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "access_point_details" {
  type        = map(string)
  description = "Map of EFS paths to their corresponding access point IDs"
}

variable "public_subnet_ids" {
  type = list(string)
}




#------------------------------------------------------------------------------
#---# Autoscaling credentials   --------------------------------------------------------------------------

#------------------------------------------------------------------------------
# AWS ECS SERVICE AUTOSCALING
#------------------------------------------------------------------------------
variable "max_cpu_threshold" {
  description = "Threshold for max CPU usage"
  default     = "60"
  type        = string
}
variable "min_cpu_threshold" {
  description = "Threshold for min CPU usage"
  default     = "45"
  type        = string
}

variable "max_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for max cpu metric alarm"
  default     = "3"
  type        = string
}
variable "min_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for min cpu metric alarm"
  default     = "3"
  type        = string
}

variable "max_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for max cpu metric alarm"
  default     = "60"
  type        = string
}
variable "min_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for min cpu metric alarm"
  default     = "60"
  type        = string
}

variable "scale_target_max_capacity" {
  description = "The max capacity of the scalable target"
  default     = 5
  type        = number
}

variable "scale_target_min_capacity" {
  description = "The min capacity of the scalable target"
  default     = 0
  type        = number
}


variable "scale_in_cooldown" {
  description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}
variable "scale_out_cooldown" {
  description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}

variable "cpu_target_value" {
   description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}

variable "memory_target_value" {
  description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}

variable "min_memory_threshold" {
  description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}


variable "min_memory_evaluation_period" {
  description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}

variable "min_memory_period" {
  description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}

variable "max_memory_evaluation_period" {
  description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}

variable "max_memory_period" {
  description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}

variable "max_memory_threshold" {
  description = "Cooldown period for scaling actions"
  type        = number
  default     = 60 // Default value, adjust as needed
}

variable "ecs_service_desired_count" {
  type = number
  default = 0
}

#------------------------------------------------------------------------------
# AWS Cloudwatch
#------------------------------------------------------------------------------

variable "log_group_names_without_port" {
  description = "List of CloudWatch log group names"
  type        = list(string)
  default     = ["ISSUANCE_SERVICE","CONNECTION_SERVICE", "LEDGER_SERVICE", "AGENT_SERVICE", "ORGNIZATION_SERVICE", "GEOLOCATION_SERVICE", "NOTIFICATION_SERVICE", "USER_SERVICE", "UTILITY_SERVICE", "VERIFICATION_SERVICE"]
}

variable "log_group_names_with_port" {
  description = "List of CloudWatch log group names"
  type        = list(string)
  default     = ["API-GATEWAY-SERVICE","MEDIATOR_SERVICE", "KEYCLOAK_SERVICE"]
}