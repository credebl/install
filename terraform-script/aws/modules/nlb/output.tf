output "nlb_arn" {
  value = aws_lb.nlb.arn
}

output "nats_websocket_tg_arns" {
  value = aws_lb_target_group.nats_websocket_tg[*].arn
}

output "nats_leaf_connection_tg_arns" {
  value = aws_lb_target_group.nats_leaf_connection_tg[*].arn
}

output "nats_listener_arns" {
  value = concat(
    aws_lb_listener.nats_websocket_listener[*].arn,
    aws_lb_listener.nats_leaf_connection_listener[*].arn
  )
}
