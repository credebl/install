variable "region" {} # provide aws region
variable "project_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "environment" {}

# VPC configurations
variable "vpc_cidr" {}
variable "availability_zone" {
  type        = list(string)
  description = "Availability Zone"
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

variable "private_route_table_names" {
  description = "Names for the private route tables"
  type        = list(string)
}



# ECR
variable "repo_name" {}

# ec2 variable
variable "nats_seed" {
  type        = list(string)
  description = "List of nkey values for NATS users"

}
variable "nats_instance_type" {
  description = "instance_type"
  type        = string
}
variable "nats_instance_tag" {
  description = "Tag given to each deployed Instance"
  type        = list(string)
}

variable "nats_counter" {
  description = "Number of instances to launch"
  type        = number
}

variable "db_counter" {
  description = "Number of instances to launch"
  type        = number
}



variable "db_instance_type" {
  type = string
}
variable "db_instance_tag" {
  type = list(string)
}

# variable "db_ami" {
#   type = string

# }

# variable "nats_ami" {
#   type = string

# }

#basion
variable "basion_ami_id" {
  type = string
}

variable "basion_instance_type" {
  type = string
}

variable "db_users" {
  type = list(string)
  default = [ "mediator_user", "keycloak_user" ]
}
variable "db_passwords" {
  type = list(string)
}
variable "db_names" {
  type = list(string)
  default = [ "mediator_db", "keycloak_db" ]
}

# taskdefirnition credentials

variable "cpu_units" {
  type = string
}
variable "memory_units" {
  type = string
}


variable "cpuArchitecture" {
  type = string
}

variable "cluster_name" {
  type = string
}


# RDS for credo and platform
variable "databases" {
  type = map(object({
      database_name                          = string
      database_master_user                   = string
      database_master_user_password          = string
      allocated_storage                      = number
      database_instance_class                = string
      allow_public_access                    = bool
      use_multiple_availability_zones        = bool
      storage_type                           = string
      storage_iops                           = number
      max_allocated_storage                  = number
      allow_major_version_upgrade            = string
      enable_automatic_minor_version_upgrade = string
      enable_performance_insights            = string
       skip_final_snapshot                    = string
      backup_retention_period                = number
      backup_window                          = string
      maintenance_window                     = string
     
      # Add other variables as needed
    }))
}