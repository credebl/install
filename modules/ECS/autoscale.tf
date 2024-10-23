#------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Target
#------------------------------------------------------------------------------
resource "aws_appautoscaling_target" "scale_target" {
  for_each = toset(local.autoscale_services)

  service_namespace  = "ecs"
  resource_id        = "service/${var.environment}-${var.cluster_name}/${each.key}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.scale_target_min_capacity
  max_capacity       = var.scale_target_max_capacity
  depends_on = [
    aws_ecs_service.agent_provisioning_service,
    aws_ecs_service.withport_service,
    aws_ecs_service.withoutport_service
  ]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarms for CPU High
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  for_each = toset(local.autoscale_services)

  alarm_name          = "${var.environment}-${lower(each.key)}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.max_cpu_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.max_cpu_period
  statistic           = "Maximum"
  threshold           = var.max_cpu_threshold
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = each.key
  }
  alarm_actions = [
    aws_appautoscaling_policy.cpu_target_tracking_policy[each.key].arn
  ]
  depends_on = [
    aws_appautoscaling_target.scale_target,
    aws_ecs_service.withport_service,
    aws_appautoscaling_policy.cpu_target_tracking_policy
  ]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarms for CPU Low
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low_alarm" {
  for_each = toset(local.autoscale_services)

  alarm_name          = "${var.environment}-${lower(each.key)}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.min_cpu_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.min_cpu_period
  statistic           = "Average"
  threshold           = var.min_cpu_threshold
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = each.key
  }
  alarm_actions = [
    aws_appautoscaling_policy.cpu_target_tracking_policy[each.key].arn
  ]
  depends_on = [
    aws_appautoscaling_target.scale_target,
    aws_ecs_service.withport_service,
    aws_appautoscaling_policy.cpu_target_tracking_policy
  ]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarms for Memory High
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_high_alarm" {
  for_each = toset(local.autoscale_services)

  alarm_name          = "${var.environment}-${lower(each.key)}-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.max_memory_evaluation_period
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.max_memory_period
  statistic           = "Maximum"
  threshold           = var.max_memory_threshold
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = each.key
  }
  alarm_actions = [
    aws_appautoscaling_policy.memory_target_tracking_policy[each.key].arn
  ]
  depends_on = [
    aws_appautoscaling_target.scale_target,
    aws_ecs_service.withport_service,
    aws_appautoscaling_policy.memory_target_tracking_policy
  ]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarms for Memory Low
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_low_alarm" {
  for_each = toset(local.autoscale_services)

  alarm_name          = "${var.environment}-${lower(each.key)}-memory-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.min_memory_evaluation_period
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.min_memory_period
  statistic           = "Average"
  threshold           = var.min_memory_threshold
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = each.key
  }
  alarm_actions = [
    aws_appautoscaling_policy.memory_target_tracking_policy[each.key].arn
  ]
  depends_on = [
    aws_appautoscaling_target.scale_target,
    aws_ecs_service.withport_service,
    aws_appautoscaling_policy.memory_target_tracking_policy
  ]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Target Tracking Scaling Policy for Memory
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "memory_target_tracking_policy" {
  for_each = toset(local.autoscale_services)

  name               = "${var.environment}-${lower(each.key)}-memory-target-tracking-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.scale_target[each.key].resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_target_value   # Target Memory utilization percentage
    scale_in_cooldown  = var.scale_in_cooldown     # Time (in seconds) to wait after a scale-in
    scale_out_cooldown = var.scale_out_cooldown    # Time (in seconds) to wait after a scale-out
  }
  depends_on = [
    aws_appautoscaling_target.scale_target,
    aws_ecs_service.withport_service
  ]
}

#------------------------------------------------------------------------------
# AWS Auto Scaling - Target Tracking Scaling Policy for CPU
#------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "cpu_target_tracking_policy" {
  for_each = toset(local.autoscale_services)

  name               = "${var.environment}-${lower(each.key)}-cpu-target-tracking-policy"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.scale_target[each.key].resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value     # Target CPU utilization percentage
    scale_in_cooldown  = var.scale_in_cooldown    # Time (in seconds) to wait after a scale-in
    scale_out_cooldown = var.scale_out_cooldown   # Time (in seconds) to wait after a scale-out
  }
  depends_on = [
    aws_appautoscaling_target.scale_target,
    aws_ecs_service.withport_service
  ]
}
