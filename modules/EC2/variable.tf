
variable "project_name" {}
variable "environment" {}

# ................................................
# nats configuration
# ................................................
variable "private_app_subnet_ids" {
  type = list(string)
}

variable "nats_seed" {
  type        = list(string)
  description = "List of nkey values for NATS users"
}
variable "nats_security_group_ids" {
  type = map(string)
}

variable "nats_instance_type" {
  type        = string
  default = "m6g.large"
}
variable "nats_instance_tag" {
  description = "Tag given to each deployed Instance"
  type        = list(string)
  default = ["nats1", "nats2", "nats3"]
}
variable "nats_counter" {
  description = "Number of instances to launch"
  type        = number
  default = 3
}

# ................................................
#db configuration
# ................................................

variable "private_db_subnet_ids" {}
variable "mediator_db_sg_id" {}
variable "keycloak_db_sg_id" {}
variable "mediator_db_port" {}
variable "keycloak_db_port" {}
variable "db_instance_tag" {
  type = list(string)
}

variable "db_counter" {
  description = "Number of instances to launch"
  type        = number
}
variable "db_instance_type" {
  type = string
}
# variable "db_ami" {
#   type = string

# }
variable "db_users" {
  type = list(string)
}
variable "db_passwords" {
  type = list(string)
}
variable "db_names" {
  type = list(string)
}

# ................................................
#basion credentials
# ................................................
variable "basion_ami_id" {
  type = string
}

variable "basion_instance_type" {
  type = string
}

variable "basion_sg_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "efs_dns" {}

variable "access_points" {
  type    = list(string)
  default = ["agent-config", "shemas", "port-file"]
}

variable "efs_id" {}

variable "ssm_role_name" {}
