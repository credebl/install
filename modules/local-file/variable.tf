variable "environmnet" {}
variable "project_name" {}



variable "db_instance_private_ipse" {
 type =  map(string)
}

variable "nats_instance_private_ips" {
  type =  map(string)
}

variable "mediator_db_port" {}
variable "keycloak_db_port" {}

variable "db_users" {
  type = list(string)
}
variable "db_passwords" {
  type = list(string)
}
variable "db_names" {
  type = list(string)
}

variable "RDS_database_port" {
  type = map(number)
}

variable "RDS_database_name" {
  type = map(string)
}


variable "RDS_database_user" {
  type = map(string)
}

variable "RDS_database_host" {
  type = map(string)
}