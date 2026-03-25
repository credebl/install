# Create NLB for NATS services
resource "aws_lb" "nlb" {
  name               = "${var.environment}-${var.project_name}-NLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids
  security_groups    = [ var.nlb_security_group_id ]
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-nlb"
  }
}

# NATS Target Groups with conditional count
resource "aws_lb_target_group" "nats_websocket_tg" {
  count       = lower(var.environment) == "prod"  || var.natscluster == true  ? 3 : 1
  name        = upper("${var.environment}-${var.project_name}-nats-ws-${count.index + 1}-tg")
  target_type = "ip"
  port        = 8442 + count.index
  protocol    = "TCP"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "TCP"
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-nats-${count.index + 1}-tg"
  }
}

# NATS Target Groups with conditional count
resource "aws_lb_target_group" "nats_leaf_connection_tg" {
  count       = lower(var.environment) == "prod"  || var.natscluster == true  ? 3 : 1
  name        = upper("${var.environment}-${var.project_name}-nats-lf-${count.index + 1}-tg")
  target_type = "ip"
  port        = 7422 + count.index
  protocol    = "TCP"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "TCP"
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-nats-${count.index + 1}-tg"
  }
}

# NLB Listeners with conditional count
resource "aws_lb_listener" "nats_websocket_listener" {
  count             = lower(var.environment) == "prod"  || var.natscluster == true  ? 3 : 1
  load_balancer_arn = aws_lb.nlb.arn
  port              = 8442 + count.index
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nats_websocket_tg[count.index].arn
  }
}

# NLB Listeners with conditional count
resource "aws_lb_listener" "nats_leaf_connection_listener" {
  count             = lower(var.environment) == "prod"  || var.natscluster == true  ? 3 : 1
  load_balancer_arn = aws_lb.nlb.arn
  port              = 7422 + count.index
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nats_leaf_connection_tg[count.index].arn
  }
}
