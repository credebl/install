variable "aws_region" {}
variable "vpc_cidr" {}
variable "project_name" {}
variable "environment" {}
variable "public_subnet_cidr" {
  type = list(string)
}
variable "private_app_subnet_cidr" {
  type = list(string)
}
variable "private_db_subnet_cidr" {
  type = list(string)
}

variable "nat_gateway_count" {
  type = number
  default = 3
}

variable "private_route_table_count" {
  type = number
  default = 3
}