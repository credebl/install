variable "environment" {}
variable "project_name" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "vpc_id" {}
variable "nlb_security_group_id" {}
variable "natscluster" {
  default = true
}