variable "environment" {}
variable "project_name" {}
variable "vpc_id" {}
variable "alb_security_group_ids" {}
variable "SERVICE_CONFIG" {}
variable "app_security_group_ids" {
  type = map(string)
}


variable "public_subnet_ids" {
  
}

variable "nats_alb_security_group_ids" {
  
}
variable "nats_security_group_ids" {
  type = map(string)
}
variable "certificate_arn" {}
variable "domain_name" {}