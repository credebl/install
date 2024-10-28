resource "aws_efs_file_system" "efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = "${var.environment}-EFS"
   }
 }


resource "aws_efs_mount_target" "efs-mt" {
   count = length(var.private_app_subnet_ids)
   file_system_id  = aws_efs_file_system.efs.id
   subnet_id = var.private_app_subnet_ids[count.index]
   security_groups = [var.efs_sg_id]
 }


 
