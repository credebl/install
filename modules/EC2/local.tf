locals {
  db_security_groups = [
    var.mediator_db_sg_id,
    var.keycloak_db_sg_id
    
  ]
}

locals {
  db_port = [var.mediator_db_port, var.keycloak_db_port]
}

# Filter out null values for the security group IDs
# Local to filter out null values from security group IDs
locals {
  nats_security_groups = [
    for i in range(var.nats_counter) : lookup(var.nats_security_group_ids, "nats-sg${i + 1}", null)
    if lookup(var.nats_security_group_ids, "nats-sg${i + 1}", null) != null
  ]
}



# userdata for linux

locals {
  user_data_script = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo usermod -a -G docker ec2-user
    sudo yum install wget -y
    wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
    sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
    sudo chmod -v +x /usr/local/bin/docker-compose
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    mkdir -p /home/ec2-user/workdir
    nano /home/ec2-user/workdir/docker-compose.yml
  EOF
}

# fetch nats ip
locals {
  nats_routes = [for instance in aws_instance.nats_ec2 : "nats://${instance.private_ip}:4245"]
}

locals {
  nats_ip = join(",", [for instance in aws_instance.nats_ec2 : instance.private_ip])
}

locals {
  basion_user_data_script = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo usermod -a -G docker ec2-user
    sudo yum install wget -y
    wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
    sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
    sudo chmod -v +x /usr/local/bin/docker-compose
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    mkdir -p /home/ec2-user/workdir
    mkdir -p /mnt/efs
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${var.efs_dns}:/ /mnt/efs
    sudo mkdir -p /mnt/efs/${var.access_points[0]} /mnt/efs/${var.access_points[1]} /mnt/efs/${var.access_points[2]}
    # sudo chmod 777 /mnt/efs/${var.access_points[1]}
  EOF
}

