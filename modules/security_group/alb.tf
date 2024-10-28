
# Create Mediator ALB Security Group
resource "aws_security_group" "mediator_alb_sg" {
  name        = "${var.environment}-mediator-alb-sg"
  description = "Allow Mediator ALB access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.alb_ports
    
    content {
      description = "Mediator ALB port access"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Keycloak ALB Security Group
resource "aws_security_group" "keycloak_alb_sg" {
  name        = "${var.environment}-keycloak-alb-sg"
  description = "Allow Keycloak ALB access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.alb_ports
    content {
      description = "Keycloak ALB port access"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create Platform ALB Security Group
resource "aws_security_group" "platform_alb_sg" {
  name        = "${var.environment}-platform-alb-sg"
  description = "Allow Platform ALB access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.alb_ports
    content {
      description = "Platform ALB port access"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}



