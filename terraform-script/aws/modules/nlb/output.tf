output "nlb_arn" {
  value = aws_lb.nlb.arn
}

output "nats_tg_arns" {
  value = aws_lb_target_group.nats_tg[*].arn
}

output "nats_listener_arns" {
  value = aws_lb_listener.nats_listener[*].arn
}
