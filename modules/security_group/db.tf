# Create Keycloak DB Security Group running on EC2
resource "aws_security_group" "keycloak_db_sg" {
  name        = "${var.environment}-keycloak-db-sg"
  description = "Allow Keycloak DB access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database port access to Keycloak SG"
    from_port       = var.db_port.keycloak_db_port
    to_port         = var.db_port.keycloak_db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.keycloak_sg.id, aws_security_group.basion_sg.id]
  }

  ingress {
    description     = "SSH access to Basion SG"
    from_port       = var.db_port.ssh_port
    to_port         = var.db_port.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.basion_sg.id]
  }

  egress {
    description     = "Database port access to Keycloak SG"
    from_port       = var.db_port.keycloak_db_port
    to_port         = var.db_port.keycloak_db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.keycloak_sg.id, aws_security_group.basion_sg.id]
  }

  egress {
    description     = "SSH access to Basion SG"
    from_port       = var.db_port.ssh_port
    to_port         = var.db_port.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.basion_sg.id]
  }
  
  dynamic "egress" {
    for_each = var.alb_ports
    #iterator = "alb_port"
   
    content {
      description = "outbound https and https access"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  depends_on = [ aws_security_group.keycloak_alb_sg , aws_security_group.basion_sg]
}



# Create Mediator DB Security Group running on EC2
resource "aws_security_group" "mediator_db_sg" {
  name        = "${var.environment}-mediator-db-sg"
  description = "Allow Mediator DB access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database port access for Mediator SG"
    from_port       = var.db_port.mediator_db_port
    to_port         = var.db_port.mediator_db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.mediator_sg.id, aws_security_group.basion_sg.id]
  }

  ingress {
    description     = "SSH access to Basion SG"
    from_port       = var.db_port.ssh_port
    to_port         = var.db_port.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.basion_sg.id]
  }

  egress {
    description     = "Database port access for Mediator SG"
    from_port       = var.db_port.mediator_db_port
    to_port         = var.db_port.mediator_db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.mediator_sg.id, aws_security_group.basion_sg.id]
  }

  egress {
    description     = "SSH access to Basion SG"
    from_port       = var.db_port.ssh_port
    to_port         = var.db_port.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.basion_sg.id]
  }

  dynamic "egress" {
    for_each = var.alb_ports
   # iterator = "alb_port"
   
    content {
      description = "outbound https and https access"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  depends_on = [ aws_security_group.mediator_sg , aws_security_group.basion_sg]
}


# Create Credo DB Security Group running on RDS
resource "aws_security_group" "credo_db_sg" {
  name        = "${var.environment}-credo-db-sg"
  description = "Allow Credo DB access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database port access"
    from_port       = var.db_port.credo_db_port
    to_port         = var.db_port.credo_db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.keycloak_sg.id, aws_security_group.basion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    security_groups = [aws_security_group.basion_sg.id]
  }
}

# Create Platform DB Security Group running on RDS
resource "aws_security_group" "platform_db_sg" {
  name        = "${var.environment}-platform-db-sg"
  description = "Allow Platform DB access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database port access for Platform SG"
    from_port       = var.db_port.platform_db_port
    to_port         = var.db_port.platform_db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.platform_sg.id, aws_security_group.basion_sg.id]
  }

  egress {
    description     = "Database port access for Platform SG"
    from_port       = var.db_port.platform_db_port
    to_port         = var.db_port.platform_db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.platform_sg.id, aws_security_group.basion_sg.id]
  }


  }

