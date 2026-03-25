resource "aws_efs_file_system" "credo_efs" {
  creation_token   = "${var.environment}-${var.project_name}-credo-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "${var.environment}-${var.project_name}-CREDO-EFS"
  }
}


resource "aws_efs_mount_target" "credo_efs_mt" {
  count           = length(var.private_app_subnet_ids)
  file_system_id  = aws_efs_file_system.credo_efs.id
  subnet_id       = var.private_app_subnet_ids[count.index]
  security_groups = [var.efs_sg_id] # Adjust as needed
}


resource "aws_efs_file_system" "nats_efs" {
  count            = var.natscluster ? 3 : 1
  creation_token   = "${var.environment}-${var.project_name}-nats-efs-${count.index + 1}"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "${var.environment}-${var.project_name}-NATS-EFS-${count.index + 1}"
  }
}

resource "aws_efs_mount_target" "nats_efs_mt" {
  count = var.natscluster ? length(var.private_app_subnet_ids) * 3 : length(var.private_app_subnet_ids)

  file_system_id  = aws_efs_file_system.nats_efs[floor(count.index / length(var.private_app_subnet_ids))].id
  subnet_id       = var.private_app_subnet_ids[count.index % length(var.private_app_subnet_ids)]
  security_groups = [var.efs_sg_id]
}

# Access point for seed config file
resource "aws_efs_access_point" "seed_access_point" {
  file_system_id = aws_efs_file_system.credo_efs.id
  root_directory {
    path = "/seed"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "777"
    }
  }
  posix_user {
    gid = 0
    uid = 0
  }
}
