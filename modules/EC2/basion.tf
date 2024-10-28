# Resource to create EC2 instances
resource "aws_instance" "basion_ec2" {
  ami                         = var.basion_ami_id
  instance_type               = var.basion_instance_type
  security_groups             = [var.basion_sg_id]
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_ids[0]
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  user_data                   = local.basion_user_data_script
  tags = {
    Name    = "${var.environment}-basion"
    project = var.project_name
  }

depends_on = [ aws_instance.db_ec2,aws_instance.nats_ec2,local_file.nats_config_file,var.efs_dns]


}

