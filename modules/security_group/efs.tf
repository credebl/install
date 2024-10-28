# Create EFS Security Group
resource "aws_security_group" "efs_sg" {
  name        = "${var.environment}-efs-sg"
  description = "Allow EFS access"
  vpc_id      = var.vpc_id

  ingress {
    description     = "EFS port access to basion and platform sg"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.platform_sg.id, aws_security_group.basion_sg.id]
  }

  egress {
    description     = "EFS port access to basion and platform sg"
    from_port       = 0
    to_port         = 0
    protocol        = -1
   cidr_blocks = ["0.0.0.0/0"]
  }
depends_on = [ aws_security_group.basion_sg, aws_security_group.platform_sg]
}
