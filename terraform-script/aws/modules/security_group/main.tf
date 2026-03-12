# ALB Security Group for each service with port
resource "aws_security_group" "ALB_SG" {

  name   = "${var.project_name}_${var.environment}_ALB_SG"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = toset([80, 443])
    content {
      description = "ALB port access"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "${var.project_name}_${var.environment}_ALB_SG"
  }
}

# Security group for the application, with ingress rules for each app service
resource "aws_security_group" "APP_SG" {
  for_each = local.service_map

  name   = upper("${var.project_name}_${var.environment}-${each.key}_SG")
  vpc_id = var.vpc_id

  ingress {
    description     = "${each.key} App port access"
    from_port       = each.value # Application's own port
    to_port         = each.value
    protocol        = "tcp"
    security_groups = [aws_security_group.ALB_SG.id] # Ensure each.key exists in ALB_SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}_${var.environment}-${each.key}_APP_SG"
  }
}


# Define Security Group for NATS ALB with conditional count based on the environment
resource "aws_security_group" "NATS_ALB_SG" {
  name   = "${var.project_name}_${var.environment}_NATS_NLB_SG"
  vpc_id = var.vpc_id

  # Dynamic ingress rule to allow traffic on ports with count-based increment
  dynamic "ingress" {
    for_each = lower(var.environment) == "prod" || var.natscluster ? toset([
      7422, 7423, 7424,
      8442, 8443, 8444
    ]) : toset([
      7422, 8442
    ])

    content {
      description = "Allow ALB port access"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_${var.environment}_NATS_ALB_SG"
  }
}



# Define Security Group for NATS with conditional count based on the environment
resource "aws_security_group" "NATS_SG" {
  name   = "${var.project_name}_${var.environment}_NATS_SG"
  vpc_id = var.vpc_id

  # Ingress rule for allowing traffic from the ALB security group
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # Allow all traffic
    security_groups = [aws_security_group.NATS_ALB_SG.id]
  }
    dynamic "ingress" {
    for_each = lower(var.environment) == "prod" || var.natscluster ? toset([
      4222, 4223, 4224,
      8222, 8223, 8224,
      6222, 6223, 6224,
    ]) : toset([
      4222, 8222, 6222
    ])
    content {
      description = "Allow ALB port access"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_${var.environment}_NATS_SG"
  }
}

resource "aws_security_group" "RDS_DB_SG" {
  name = "${var.project_name}_${var.environment}_DB_SG"
  vpc_id = var.vpc_id

    ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups  = [aws_security_group.APP_SG["platform"].id, aws_security_group.SEED_SG.id]
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "REDIS_SG" {
  name   = "${var.project_name}_${var.environment}_REDIS_SG"
  vpc_id = var.vpc_id

  ingress {
    description     = "${local.REDIS_CONFIG.SERVICE_NAME} access for API_GATEWAY"
    from_port       = local.REDIS_CONFIG.PORT
    to_port         = local.REDIS_CONFIG.PORT
    protocol        = "tcp"
    security_groups = [aws_security_group.APP_SG["platform"].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}_${var.environment}_REDIS_SG"
  }
}

resource "aws_security_group" "CREDO_SG" {
  name   = "${var.project_name}_${var.environment}_CREDO_SG"
  vpc_id = var.vpc_id

  ingress {
    description     = "ALB access to CREDO"
    from_port       = var.credo_port
    to_port         = var.credo_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ALB_SG.id]
  }
  ingress {
  description     = "ALB access to CREDO"
  from_port       = var.credo_inbound_port
  to_port         = var.credo_inbound_port
  protocol        = "tcp"
  security_groups = [aws_security_group.ALB_SG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}_${var.environment}_CREDO_SG"
  }
}

# Define Security Group for EFS with inbound access for API_GATEWAY and NATS SG
resource "aws_security_group" "EFS_SG" {
  name   = "${var.project_name}_${var.environment}_EFS_SG"
  vpc_id = var.vpc_id

  ingress {
    description = "EFS port ${local.EFS_PORT} access for API_GATEWAY"
    from_port   = local.EFS_PORT
    to_port     = local.EFS_PORT
    protocol    = "tcp"
    # security_groups = flatten([
    #   [aws_security_group.APP_SG["api-gateway"].id],
    #   lower(var.environment) != "dev" ? [aws_security_group.NATS_SG.id] : []
    # ])
    security_groups = [ aws_security_group.APP_SG["platform"].id, aws_security_group.NATS_SG.id, aws_security_group.SEED_SG.id ]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_${var.environment}_EFS_SG"
  }
}

resource "aws_security_group" "SEED_SG" {
  name   = "${var.project_name}_${var.environment}_SEED_SG"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}