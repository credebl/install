# Create Platform Security Group
resource "aws_security_group" "platform_sg" {
  name        = "${var.environment}-platform-sg"
  description = "Allow platform SG access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Port API-gateway access to alb"
    from_port       = var.app_port.platform_app_port
    to_port         = var.app_port.platform_app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.platform_alb_sg.id]
  }

  egress {
    description     = "Port API-gateway access to alb"
    from_port       = var.app_port.platform_app_port
    to_port         = var.app_port.platform_app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.platform_alb_sg.id]
  }

  egress {
    description     = "Port API-gateway access to db"
    from_port       = 0
    to_port         = 0
    protocol        = -1
   # security_groups = [aws_security_group.platform_db_sg.id]
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  depends_on = [ aws_security_group.platform_alb_sg]
}


# Create keycloak Security Group
resource "aws_security_group" "keycloak_sg" {
  name        = "${var.environment}-keycloak-sg"
  description = "Allow keycloak SG access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Port keycloak access to alb"
    from_port       = var.app_port.keycloak_app_port
    to_port         = var.app_port.keycloak_app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.platform_alb_sg.id]
  }

  egress {
    description     = "Port keycloak access to alb"
    from_port       = var.app_port.keycloak_app_port
    to_port         = var.app_port.keycloak_app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.platform_alb_sg.id]
  }

  egress {
    description     = "Port keycloak access to db"
    from_port       = var.app_port.keycloak_app_port
    to_port         = var.app_port.keycloak_app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.platform_db_sg.id]
  }
  depends_on = [aws_security_group.keycloak_sg]
}

# Create Platform Security Group
resource "aws_security_group" "mediator_sg" {
  name        = "${var.environment}-mediator-sg"
  description = "Allow mediator SG access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Port mediator access to alb"
    from_port       = var.app_port.mediator_app_port
    to_port         = var.app_port.mediator_app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.mediator_alb_sg.id]
  }

  egress {
    description     = "Port mediator access to alb"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.mediator_alb_sg]
}

