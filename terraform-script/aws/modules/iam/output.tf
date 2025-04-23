output "ssm_role_name" {
  value = aws_iam_role.ssm_role.name
}

output "ecs_tasks_execution_role_arn" {
  value = aws_iam_role.ecs_tasks_execution_role.arn
}


output "ecs_tasks_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "rds_monitoring_role_arn" {
  value = aws_iam_role.rds_monitoring_role.arn
}
