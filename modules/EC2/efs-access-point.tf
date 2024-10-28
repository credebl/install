resource "aws_efs_access_point" "access_point" {
  for_each = toset(var.access_points)
  
  file_system_id = var.efs_id
  root_directory {
    path =  "/${each.value}"  # Corrected syntax to include each.value

    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }
depends_on = [ aws_instance.basion_ec2 ]
}

