# Create an ALB for each service with a port in SERVICE_CONFIG
resource "aws_lb" "alb" {
  name               = upper(replace("${var.environment}-${var.project_name}-alb", "_", "-"))
  internal           = false
  load_balancer_type = "application"
  security_groups    = values(var.alb_security_group_ids) # Updated this line to access the security group ID directly
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

# Create target groups for each service with ports defined in SERVICE_CONFIG
resource "aws_lb_target_group" "app_tg" {
  for_each = { for service in var.SERVICE_CONFIG.WITH_PORT : service.SERVICE_NAME => service }

  name        = upper(replace("${var.environment}-${var.project_name}-${each.key}-tg", "_", "-"))
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  # Configure health checks using each service's health check settings
  health_check {
    path                = each.value.health_check.path
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    matcher             = each.value.health_check.matcher
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-${each.value.SERVICE_NAME}-tg"
  }
}


resource "aws_lb_target_group" "credo_tg" {
  name        = upper("${var.environment}-${var.project_name}-credo-tg")
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/agent"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200,404,401"
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-credo-tg"
  }
}

# Additional TG for CREDO-INBOUND
resource "aws_lb_target_group" "credo_inbound_tg" {
  name        = upper("${var.environment}-${var.project_name}-credo-inbound-tg")
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200,404,302"
  }

  tags = {
    Name = "${var.environment}-${var.project_name}-credo-inbound-tg"
  }
}


# HTTP Listener for each ALB (redirects HTTP to HTTPS)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# Listener for HTTPS (port 443) forwarding to appropriate target groups
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "https_service_rules" {
  for_each = aws_lb_target_group.app_tg

  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100 + index(tolist(keys(aws_lb_target_group.app_tg)), each.key)

  action {
    type             = "forward"
    target_group_arn = each.value.arn
  }

  condition {
    host_header {
        values = [lower("${var.environment}-${each.key}.${var.domain_name}")]
    }
  }
}

resource "aws_lb_listener_rule" "https_credo_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.credo_tg.arn
  }

  condition {
    host_header {
        values = [lower("${var.environment}-agent.${var.domain_name}")]
    }
  }
}

resource "aws_lb_listener_rule" "https_credo_inbound_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 201

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.credo_inbound_tg.arn
  }

  condition {
    host_header {
        values = [lower("${var.environment}-inbound-agent.${var.domain_name}")]
    }
  }
}
