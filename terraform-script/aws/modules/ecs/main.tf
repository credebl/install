
module "taskdenitions" {
  source = "./taskdefinition"
  ecs_tasks_execution_role_arn = var.ecs_tasks_execution_role_arn
  ecs_tasks_role_arn = var.ecs_tasks_role_arn
  env_file_bucket_arn = var.env_file_bucket_arn
  credo_efs_id = var.credo_efs_id
  nats_efs_id = var.nats_efs_id
  environment = var.environment
  project_name = var .project_name
  log_groups_nats = var.log_groups_nats
  log_groups_with_port = var.log_groups_with_port
  log_groups_without_port = var.log_groups_without_port
  app_security_group_ids = var.app_security_group_ids
  vpc_id = var.vpc_id
  nats_security_group_ids = var.nats_security_group_ids
  public_subnet_ids = var.public_subnet_ids
  region = var.region
  alb_security_group_ids = var.alb_security_group_ids
  SERVICE_CONFIG = var.SERVICE_CONFIG
  AGENT_PROVISIONING_SERVICE = var.AGENT_PROVISIONING_SERVICE
  log_groups_agent_provisioning_service = var.log_groups_agent_provisioning_service
  REDIS_CONFIG = var.REDIS_CONFIG
  credo_inbound_port = var.credo_inbound_port
  credo_port = var.credo_port
  nats_efs_access_point_id = var.nats_efs_access_point_id
}

module "service" {
  source = "./service"
  private_app_subnet_ids = var.private_app_subnet_ids
  environment = var.environment
  project_name = var.project_name
  nats_service_task_definitions = module.taskdenitions.nats_service_task_definitions
  with_port_task_definitions = module.taskdenitions.with_port_task_definitions
  without_port_task_definitions = module.taskdenitions.without_port_task_definitions
  target_group_arns = var.target_group_arns
  agent_provisioning_service_task_definition = module.taskdenitions.agent_provisioning_service_task_definition
  app_security_group_ids = var.app_security_group_ids
  AGENT_PROVISIONING_SERVICE =var.AGENT_PROVISIONING_SERVICE
  SERVICE_CONFIG=var.SERVICE_CONFIG
  nats_alb_security_group_ids = var.nats_alb_security_group_ids
  nats_security_group_ids = var.nats_security_group_ids
  redis_sg_id = var.redis_sg_id
  redis_server_task_definitions_arn=module.taskdenitions.redis_server_task_definitions_arn
  REDIS_CONFIG = var.REDIS_CONFIG
  seed_task_definition_arn = module.taskdenitions.seed_task_definition_arn
}