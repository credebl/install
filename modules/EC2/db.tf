# Data source to find the latest ARM64 Amazon Linux 2023 AMI
data "aws_ami" "linux_ami_db" {
  most_recent = true

  filter {
    name = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# EC2 instances for DB (if applicable)
resource "aws_instance" "db_ec2" {
  count                       = var.db_counter 
  ami                         = data.aws_ami.linux_ami_db.id
  instance_type               = var.db_instance_type
  security_groups             = [local.db_security_groups[count.index]]
  associate_public_ip_address = false
  subnet_id                   = var.private_db_subnet_ids[0]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  user_data = templatefile("${path.module}/db-user-data.sh", {
    db_user     = var.db_users[count.index]
    db_password = var.db_passwords[count.index]
    db_name     = var.db_names[count.index]
    db_port     = local.db_port[count.index]
  })
  tags = {
    Name    = "${var.environment}-${var.db_instance_tag[count.index]}"
    project = var.project_name
  }
}
