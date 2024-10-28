output "nats_instance_ids" {
  value = {
    for instance in aws_instance.nats_ec2 : instance.tags["Name"] => instance.id
    # Optionally, filter based on specific naming conventions if needed
  }
}

output "nats_instance_public_ips" {
  description = "Map of NATS EC2 instance names to their public IPs"
  value = {
    for instance in aws_instance.nats_ec2 : instance.tags["Name"] => instance.public_ip
  }
}

output "nats_instance_private_ips" {
  description = "Map of NATS EC2 instance names to their private IPs"
  value = {
    for instance in aws_instance.nats_ec2 : instance.tags["Name"] => instance.private_ip
  }
}

output "db_instance_ids" {
  value = {
    for instance in aws_instance.db_ec2 : instance.tags["Name"] => instance.id
    # Optionally, filter based on specific naming conventions if needed
  }
}

output "db_instance_public_ipsme" {
  value = {
    for instance in aws_instance.db_ec2 : instance.tags["Name"] => instance.public_ip
  }
}

output "db_instance_private_ipse" {
  value = {
    for instance in aws_instance.db_ec2 : instance.tags["Name"] => instance.private_ip
  }
}

output "basion_instance_ids" {
  value = aws_instance.basion_ec2.id
}

output "basion_instance_public_ip" {
  value = aws_instance.basion_ec2.public_ip
}

output "basion_instance_private_ip" {
  value = aws_instance.basion_ec2.private_ip
}


output "db_names" {
  value = var.db_names
}

output "db_users" {
  value = var.db_users
}

output "db_passwords" {
  value = var.db_passwords
}
#store values in localfile

resource "local_sensitive_file" "nats_instance_info" {
  content = jsonencode({
    nats_instance_ids = {
      for instance in aws_instance.nats_ec2 : instance.tags["Name"] => instance.id
    }
    nats_instance_public_ips = {
      for instance in aws_instance.nats_ec2 : instance.tags["Name"] => instance.public_ip
    }
    nats_instance_private_ips = {
      for instance in aws_instance.nats_ec2 : instance.tags["Name"] => instance.private_ip
    }
  })
  filename = "${path.module}/ec2-info/nats_instance_info.json"
}






output "access_points" {
  value = var.access_points
}


#efs access_point
output "access_point_details" {
  value = {
    for ap in aws_efs_access_point.access_point :
    ap.root_directory[0].path => ap.id # Access the path from the first element of the list

  }
  description = "Map of EFS Access Point IDs to their root directory paths"
}

# provider "local" {}

resource "local_file" "shema_access_point_details_file" {
  content = jsonencode({
    for ap in aws_efs_access_point.access_point :
    ap.root_directory[0].path => ap.id

  })
  filename = "${path.module}/access_point_details.json"
}



