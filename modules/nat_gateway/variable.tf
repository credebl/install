variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "project_name" {}
variable "environment" {}

variable "internet_gateway_id" {}
variable "vpc_id" {}

variable "private_db_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}


variable "private_route_table_names" {
  description = "Names for the private route tables"
  type        = list(string)
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create"
  type        = number
  default     = 2
}
