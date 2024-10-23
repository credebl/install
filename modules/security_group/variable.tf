
variable "environment" {}
variable "project_name" {}
variable "vpc_id" {}
variable "alb_ports" {
    type = list(number)
    default = ["80", "443"] 
}

variable "app_port" {
  description = "Ports for the application"
  type = map(number)
  default = {
  keycloak_app_port           = 8080
  mediator_app_port           = 3000
  platform_app_port           = 5000
  schema_file_server_app_port = 3000
}

}

variable "db_port" {
  description = "Ports for the database"
  type = map(number)
  default = {
  keycloak_db_port = 5455
  platform_db_port = 5432
  mediator_db_port = 5456
  credo_db_port    = 5432
  redis_db_port    = 6379
  ssh_port         = 22
}

}

#extracted from privioud modules
variable "efs_port" {
  type = number
  default = 2049
}


#nats config file
variable "nats" {
  type = map(object({
    name          = string
    listener_port = number
    cluster_port  = number
  }))
  default = {
  "nats1" = {
    name          = "nats1"
    listener_port = 4222
    cluster_port  = 4245
  }
  "nats2" = {
    name          = "nats2"
    listener_port = 4222
    cluster_port  = 4245
  }
  "nats3" = {
    name          = "nats3"
    listener_port = 4222
    cluster_port  = 4245
  }
}

}