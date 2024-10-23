resource "aws_cloudwatch_log_group" "log_groups_without_port" {
  for_each = toset(var.log_group_names_without_port)

  name = "/ecs/${each.value}"
}

resource "aws_cloudwatch_log_group" "log_groups_with_port" {
  for_each = toset(var.log_group_names_with_port)

  name = "/ecs/${each.value}"
}

resource "aws_cloudwatch_log_group" "logs_group_schema_service" {
  name              = "/ecs/SCHEMAFILE_SERVER_SERVICE"

}

resource "aws_cloudwatch_log_group" "logs_group_agent_provisioning_service" {
  name              = "/ecs/AGENT_PROVISIONING_SERVICE_TASKDEFINITION"

}