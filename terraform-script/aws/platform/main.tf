module "root" {
  source                   = "../modules/root"
  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidr       = var.public_subnet_cidr
  private_app_subnet_cidr  = var.private_app_subnet_cidr
  private_db_subnet_cidr   = var.private_db_subnet_cidr
  profile                  = var.profile
  region                   = var.region
}

module "vpc" {
  source                  = "../modules/vpc"
  project_name            = module.root.project_name
  environment             = module.root.environment
  vpc_cidr                = module.root.vpc_cidr
  public_subnet_cidr      = module.root.public_subnet_cidr
  private_app_subnet_cidr = module.root.private_app_subnet_cidr
  private_db_subnet_cidr  = module.root.private_db_subnet_cidr
  depends_on              = [module.root]
}

module "nat_gateway" {
  source                     = "../modules/nat_gateway"
  project_name               = module.root.project_name
  environment                = module.root.environment
  vpc_id                     = module.vpc.vpc_id
  private_app_route_table_id = module.vpc.private_app_route_table_id
  private_db_route_table_id  = module.vpc.private_db_route_table_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  depends_on                 = [module.vpc, module.root]
}

module "security_groups" {
  source                     = "../modules/security_group"
  environment                = module.root.environment
  project_name               = module.root.project_name
  vpc_id                     = module.vpc.vpc_id
  credo_port                 = module.root.credo_port
  credo_inbound_port         = module.root.credo_inbound_port
  SERVICE_CONFIG             = module.root.SERVICE_CONFIG
  AGENT_PROVISIONING_SERVICE = module.root.AGENT_PROVISIONING_SERVICE
  ALB_SG                     = module.root.ALB_SG
  depends_on                 = [module.nat_gateway, module.vpc, module.root]
}

module "iam" {
  source       = "../modules/iam"
  environment  = module.root.environment
  project_name = module.root.project_name


}
module "s3" {
  source             = "../modules/s3"
  environment        = module.root.environment
  project_name       = module.root.project_name
  ecs_tasks_role_arn = module.iam.ecs_tasks_execution_role_arn

}

module "efs" {
  source                 = "../modules/efs"
  environment            = module.root.environment
  project_name           = module.root.project_name
  vpc_id                 = module.vpc.vpc_id
  efs_sg_id              = module.security_groups.efs_sg_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  depends_on             = [module.security_groups]
}

module "alb" {
  source                        = "../modules/alb"
  project_name                  = module.root.project_name
  environment                   = module.root.environment
  nats_alb_security_group_ids   = module.security_groups.nats_alb_security_group_ids
  vpc_id                        = module.vpc.vpc_id
  public_subnet_ids             = module.vpc.public_subnet_ids
  nats_security_group_ids       = module.security_groups.nats_alb_security_group_ids
  alb_security_group_ids        = module.security_groups.alb_security_group_ids
  SERVICE_CONFIG                = module.security_groups.SERVICE_CONFIG
  app_security_group_ids        = module.security_groups.app_security_group_ids
  certificate_arn               = var.certificate_arn
  domain_name                   = var.domain_name
}


module "cloudwatch_group" {
  source                     = "../modules/cloudwatch"
  environment                = module.root.environment
  project_name               = module.root.project_name
  SERVICE_CONFIG             = module.security_groups.SERVICE_CONFIG
  AGENT_PROVISIONING_SERVICE = module.security_groups.AGENT_PROVISIONING_SERVICE
  REDIS_CONFIG               = module.security_groups.REDIS_CONFIG
  depends_on                 = [module.security_groups]

}

module "ecs" {
  source                                = "../modules/ecs"
  environment                           = module.root.environment
  project_name                          = module.root.project_name
  vpc_id                                = module.vpc.vpc_id
  nats_security_group_ids               = module.security_groups.nats_security_group_ids
  public_subnet_ids                     = module.vpc.public_subnet_ids
  nats_efs_id                           = module.efs.nats_efs_id
  credo_efs_id                          = module.efs.credo_efs_id
  alb_security_group_ids                = module.security_groups.alb_security_group_ids
  log_groups_with_port                  = module.cloudwatch_group.log_groups_with_port
  log_groups_without_port               = module.cloudwatch_group.log_groups_without_port
  log_groups_nats                       = module.cloudwatch_group.log_groups_nats
  SERVICE_CONFIG                        = module.security_groups.SERVICE_CONFIG
  app_security_group_ids                = module.security_groups.app_security_group_ids
  ecs_tasks_execution_role_arn          = module.iam.ecs_tasks_execution_role_arn
  ecs_tasks_role_arn                    = module.iam.ecs_tasks_role_arn
  env_file_bucket_arn                   = module.s3.env_file_bucket_arn
  region                                = var.region
  AGENT_PROVISIONING_SERVICE            = module.security_groups.AGENT_PROVISIONING_SERVICE
  log_groups_agent_provisioning_service = module.cloudwatch_group.log_groups_agent_provisioning_service
  nats_alb_security_group_ids           = module.security_groups.nats_alb_security_group_ids
  REDIS_CONFIG                          = module.security_groups.REDIS_CONFIG
  redis_sg_id                           = module.security_groups.redis_sg_id
  target_group_arns                     = module.alb.target_group_arns
  alb_details                           = module.alb.alb_details
  env_file_bucket_id                    = module.s3.env_file_bucket_id
  private_app_subnet_ids                = module.vpc.private_app_subnet_ids
  depends_on                            = [module.cloudwatch_group, module.iam, module.efs]
  credo_inbound_port                    = module.root.credo_inbound_port
  credo_port                            = module.root.credo_port
  nats_efs_access_point_id              = module.efs.nats_efs_access_point_id
}
