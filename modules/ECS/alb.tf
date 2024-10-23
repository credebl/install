# Create a load balancer for each service
resource "aws_lb" "alb" {
  for_each = { for i, service in var.service_configs : service.env_file_suffix => service }

  name               = "${var.environment}-${each.key}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [for k in local.alb_sg_group : k]
  subnets            = var.public_subnet_ids
  tags = {
    Name = "${var.environment}-${each.key}-alb"
  }
}

# Create a target group for each service
resource "aws_lb_target_group" "tg" {
  for_each = { for i, service in var.service_configs : service.env_file_suffix => service }

  name        = "${each.key}-tg"
  target_type = "ip"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = each.value.health_check.path
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
  }

  tags = {
    Name = "${var.environment}-${each.key}-tg"
  }
}

# Create a listener for each ALB to forward traffic to the appropriate target group
resource "aws_lb_listener" "listener" {
  for_each = { for i, service in var.service_configs : service.env_file_suffix => service }

  load_balancer_arn = aws_lb.alb[each.key].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }
}

# # Optionally, create listener rules if specific conditions are needed
# resource "aws_lb_listener_rule" "rule" {
#   for_each = { for i, service in var.service_configs : service.name => service }

#   listener_arn = aws_lb_listener.listener[each.key].arn
#   priority     = 100 + each.key # Ensure unique priority

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg[each.key].arn
#   }

#   condition {
#     path_pattern {
#       values = ["*"] # Adjust this as needed for specific path patterns
#     }
#   }
# }
