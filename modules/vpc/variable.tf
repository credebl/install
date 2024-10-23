variable "region" {}
variable "project_name" {}
variable "vpc_cidr" {}
variable "availability_zone" {
  type        = list(string)
  description = "Availability Zone"
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public subnet CIDR "
  default     = []
}

variable "public_subnet_interfix" {
  type        = string
  description = "Give interfix to public subnet name"
  default     = "public"
}

variable "private_app_subnet_cidr" {
  type        = list(string)
  description = "Private subnet CIDR"
  default     = []
}

variable "private_app_subnet_interfix" {
  type        = string
  description = "Give interfix to private subnet name"
  default     = "private"
}


variable "private_db_subnet_cidr" {
  type        = list(string)
  description = "Private subnet CIDR"
  default     = []
}

variable "private_db_subnet_interfix" {
  type        = string
  description = "Give interfix to private subnet name"
  default     = "private"
}

variable "additional_tags" {
  type        = map(string)
  description = "Variable if additional tags is needed"
  default     = {}
}
variable "environment" {}

