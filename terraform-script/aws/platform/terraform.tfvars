# Generic Variables
region       = "region"
project_name = "TEST"
environment  = "DEV"
profile      = "aws profile"


# VPC Variables
vpc_cidr                = "10.0.0.0/16"
public_subnet_cidr      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
private_db_subnet_cidr  = ["10.0.5.0/24", "10.0.6.0/24"]

certificate_arn = "arn:aws:acm:us-west-1:123456789012:certificate/abcd1234-ab12-cd34-ef56-abcdef123456"
domain_name     = "example.com"
