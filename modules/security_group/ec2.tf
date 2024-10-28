# Create basion Security Group fr basion
resource "aws_security_group" "basion_sg" {
  name        = "${var.environment}-basion-sg"
  description = "Provide user access and get access of private servers"
  vpc_id      = var.vpc_id  # Ensure you specify the VPC ID if necessary

  ingress {
    description = "Allow SSH access from any IP"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting to specific IP ranges for better security
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

