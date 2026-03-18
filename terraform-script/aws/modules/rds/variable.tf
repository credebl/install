variable "project_name" {}
variable "environment" {}
variable "db_instance_class" {}
variable "db_storage_size" {
  type    = number
  default = 100
}
variable "storage_type" {
  description = "The storage type for the RDS instance."
  default     = "io2"
}
variable "max_db_storage_size" {
  default = 1000
}
variable "db_subnet_ids" {}
variable "db_username" {
  default = "postgres"
}
variable "db_name" {
  default = "postgres"
}
variable "db_sg_id" {}
variable "db_iops" {}
