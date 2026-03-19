# Generic Variables
region       = "aws_region"
project_name = "CREDEBL"
environment  = "PROD"
profile      = "aws profile_name"


certificate_arn = "arn:aws:acm:us-west-1:123456789012:certificate/abcd1234-ab12-cd34-ef56-abcdef123456"
domain_name     = "example.com"

vpc_cidr                = "10.0.0.0/16"
public_subnet_cidr      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_app_subnet_cidr = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
private_db_subnet_cidr  = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

natscluster = true