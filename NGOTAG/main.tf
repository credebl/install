module "vpc" {
  source                      = "../modules/vpc"
  region                      = var.region
  project_name                = var.project_name
  vpc_cidr                    = var.vpc_cidr
  availability_zone           = var.availability_zone
  public_subnet_cidr          = var.public_subnet_cidr
  public_subnet_interfix      = var.public_subnet_interfix
  private_app_subnet_cidr     = var.private_app_subnet_cidr
  private_app_subnet_interfix = var.private_app_subnet_interfix
  private_db_subnet_cidr      = var.private_db_subnet_cidr
  private_db_subnet_interfix  = var.private_db_subnet_interfix
  additional_tags             = var.additional_tags
  environment                 = var.environment
}

module "nat_gateway" {
  source                    = "../modules/nat_gateway"
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  project_name              = module.vpc.project_name
  internet_gateway_id       = module.vpc.internet_gateway_id
  private_app_subnet_ids    = module.vpc.private_app_subnet_ids
  private_db_subnet_ids     = module.vpc.private_db_subnet_ids
  private_route_table_names = var.private_route_table_names
  environment               = module.vpc.environment
  depends_on = [ module.vpc.environment ]
}


module "security_groups" {
  source    = "../modules/security_group"
  vpc_id    = module.vpc.vpc_id
  environment  = module.vpc.environment
  project_name = module.vpc.project_name
  depends_on = [ module.vpc.environment ]
}

# s3 bucket

module "s3" {
  source       = "../modules/s3"
  project_name = module.vpc.project_name
  environment  = module.vpc.environment
  
}

# IAM policy

module "IAM" {
  source                   = "../modules/IAM"
  env_file_bucket_id       = module.s3.env_file_bucket_id
  demo_shortning_bucket_id = module.s3.demo_shortning_bucket_id
  org_logo_bucket_id       = module.s3.org_logo_bucket_id
  project_name             = module.vpc.project_name
}

module "ECR" {
  source      = "../modules/ECR"
  repo_name   = var.repo_name
  environment = var.environment

}


# module "Platform_RDS" {
module "rds" {
  source                = "../modules/RDS"
  vpc_id                = module.vpc.vpc_id
  platform_db_sg_id     = module.security_groups.platform_alb_sg_id
  credo_db_sg_id        = module.security_groups.credo_db_sg_id
  environment           = module.vpc.environment
  project_name          = module.vpc.project_name
  databases             = var.databases
  platform_db_port      = module.security_groups.platform_db_port
  credo_db_port         = module.security_groups.credo_db_port
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  depends_on = [ module.vpc.environment,module.security_groups.platform_db_sg_id ]
 
}




# efs configuration
module "efs" {
  source                 = "../modules/EFS"
  efs_sg_id              = module.security_groups.efs_sg_id
  vpc_id                 = module.vpc.vpc_id
  environment            = module.vpc.environment
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  basion_instance_ids    = module.ec2.basion_instance_ids
  depends_on = [ module.vpc.environment ]
}


# ec2 module

module "ec2" {
  source                  = "../modules/EC2"
  private_app_subnet_ids  = module.vpc.private_app_subnet_ids
  private_db_subnet_ids   = module.vpc.private_db_subnet_ids
  environment             = module.vpc.environment
  project_name            = module.vpc.project_name
  nats_instance_tag       = var.nats_instance_tag
  nats_instance_type      = var.nats_instance_type
  nats_counter            = var.nats_counter
  db_counter              = var.db_counter
  db_instance_type        = var.db_instance_type
  db_instance_tag         = var.db_instance_tag
  keycloak_db_sg_id       = module.security_groups.keycloak_db_sg_id
  nats_security_group_ids = module.security_groups.nats_security_group_ids
  mediator_db_sg_id       = module.security_groups.mediator_db_sg_id
  ssm_role_name           = module.IAM.ssm_role_name
  basion_ami_id           = var.basion_ami_id
  basion_instance_type    = var.basion_instance_type
  basion_sg_id            = module.security_groups.basion_sg_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  nats_seed               = var.nats_seed
  efs_dns                 = module.efs.efs_dns
  efs_id                  = module.efs.efs_id
  db_names                = var.db_names
  db_passwords            = var.db_passwords
  db_users                = var.db_users
  keycloak_db_port        = module.security_groups.keycloak_db_port
  mediator_db_port        = module.security_groups.mediator_db_port
  depends_on              = [module.security_groups]


}

# ecs taskdefinition
module "ecs" {
  source                       = "../modules/ECS"
  environment                  = module.vpc.environment
  region                       = var.region
  project_name                 = module.vpc.project_name
  env_file_bucket_arn          = module.s3.env_file_bucket_arn
  repo_url                = module.ECR.repo_url
  cpu_units                    = var.cpu_units
  memory_units                 = var.memory_units
  cpuArchitecture              = var.cpuArchitecture
  ecs_tasks_execution_role_arn = module.IAM.ecs_tasks_execution_role_arn
  platform_sg_id               = module.security_groups.platform_sg_id
  private_app_subnet_ids       = module.vpc.private_app_subnet_ids
  cluster_name                 = var.cluster_name
  nats_instance_public_ips     = module.ec2.nats_instance_public_ips
  efs_id                       = module.efs.efs_id
  access_point_details         = module.ec2.access_point_details
  public_subnet_ids            = module.vpc.public_subnet_ids
  vpc_id                       = module.vpc.vpc_id
  mediator_alb_sg_id           = module.security_groups.mediator_alb_sg_id
  platform_alb_sg_id           = module.security_groups.platform_alb_sg_id
  keycloak_alb_sg_id           = module.security_groups.platform_alb_sg_id
  mediator_sg_id               = module.security_groups.mediator_db_sg_id
  keycloak_sg_id               = module.security_groups.keycloak_sg_id
  platform_database_name       = module.rds.platform_database_name
  depends_on                   = [module.ec2.nats_instance_public_ips, module.ec2.access_point_details, module.rds.private_db_subnet_ids, module.rds.platform_database_name]
}


module "local_file" {
  source = "../modules/local-file"
  project_name = module.vpc.project_name
  environmnet = module.vpc.environment
  mediator_db_port = module.security_groups.mediator_db_port
  RDS_database_name = module.rds.RDS_database_name
  RDS_database_port = module.rds.RDS_database_port
  RDS_database_user = module.rds.RDS_database_user
  RDS_database_host = module.rds.RDS_database_host
  keycloak_db_port = module.security_groups.keycloak_db_port
  nats_instance_private_ips = module.ec2.nats_instance_private_ips
  db_instance_private_ipse = module.ec2.db_instance_private_ipse
  db_names = module.ec2.db_names
  db_users = module.ec2.db_users
  db_passwords = module.ec2.db_passwords
}