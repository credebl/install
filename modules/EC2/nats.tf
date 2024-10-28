# Data source to find the latest ARM64 Amazon Linux 2023 AMI
data "aws_ami" "linux_ami" {
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

# Resource to create EC2 instances
resource "aws_instance" "nats_ec2" {
  count                       = var.nats_counter  # This should be 3
  ami                         = data.aws_ami.linux_ami.id
  instance_type               = var.nats_instance_type
  security_groups             = [values(var.nats_security_group_ids)[count.index]]
  associate_public_ip_address = false
  subnet_id                   = var.private_app_subnet_ids[0]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  user_data = file("${path.module}/nats-user-data.sh")
  tags = {
    Name    = "${var.environment}-${var.nats_instance_tag[count.index]}"
    project = var.project_name
  }
}


