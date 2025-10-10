# aws credentials
variable "profile" {}
variable "project_name" {}
variable "environment" {}
variable "region" {}

# vpc credentials
# variable "vpc_cidr" {}
# variable "public_subnet_cidr" {
#   type = list(string)
# }
# variable "private_app_subnet_cidr" {
#   type = list(string)
# }

# variable "private_db_subnet_cidr" {
#   type = list(string)
# }

#db info
variable "certificate_arn" {}
variable "domain_name" {}

variable "vpc_id" {}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_app_subnet_ids" {
  type = list(string)
}