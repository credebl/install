locals {
  project_name = var.project_name
  environment  = var.environment

  tags = {
    environment = local.environment
    project     = local.project_name
  }
}
