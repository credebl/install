# Outputs for each ALB created
output "alb_arns" {
  description = "The ARNs of the ALBs created for each service"
  value = aws_lb.alb.arn
}

# Outputs for each target group ARN
output "target_group_arns" {
  description = "The ARNs of the target groups created for each service"
  value = { for service, tg in aws_lb_target_group.app_tg : service => tg.arn }
}

# Outputs for the ALB DNS names (for each service)
output "alb_dns" {
  description = "DNS name of the shared ALB"
  value       = aws_lb.alb.dns_name
}
output "alb_details" {
  description = "Details of the shared ALB"
  value = {
    alb_arn          = aws_lb.alb.arn
    alb_dns          = aws_lb.alb.dns_name
    https_listener_arn = aws_lb_listener.https_listener.arn
  }
}