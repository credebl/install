# aws credentials
variable "profile" {}
variable "project_name" {}
variable "environment" {}
variable "region" {}

#db info
variable "certificate_arn" {}
variable "domain_name" {}

#vpc info
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "private_app_subnet_cidr" {}
variable "private_db_subnet_cidr" {}
variable "natscluster" {}

variable "image_tag" {}