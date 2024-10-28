# Create basion Security Group for NATS
resource "aws_security_group" "nats_security_group" {
  for_each = var.nats
  name        = "${var.environment}-${each.value.name}"
  description = "${each.value.name} group for ${var.environment}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [each.value.listener_port]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      security_groups = [
        aws_security_group.platform_sg.id,   # Allow access from platform SG
        # aws_security_group.nats_security_group[each.key].id  # Allow access to other NATS SGs
      ]
    }
  }
egress {

      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    
  }
}

# Create basion Security Group for NATS
resource "aws_security_group" "nats_cluster_security_group" {
  name        = "${var.environment}-nats_cluster_access-sg"
  description = "Provide cluster access and get access to NATS servers"
  vpc_id      = var.vpc_id

  # Assuming var.nats is a map with key as NATS instance name and value as the config
  dynamic "ingress" {
    for_each = { for k, v in var.nats : k => v }
    content {
      description = "Allow NATS cluster access to NATS"
      from_port   = ingress.value.cluster_port
      to_port     = ingress.value.cluster_port
      protocol    = "tcp"
      security_groups = [for sg in aws_security_group.nats_security_group : sg.id]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

