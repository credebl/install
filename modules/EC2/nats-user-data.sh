#!/bin/bash
exec > /var/log/user-data.log 2>&1

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
cat << EOF > /home/ec2-user/workdir/docker-compose.yml
version: "3.8"

services:
  nats-server-2:
    image: nats
    command: "--config ./nats.conf --server_name S1"
    ports:
      - "443:443"
      - "4222:4222"
      - "4245:4245"
    volumes:
      - ~/nats.conf:/nats.conf
    restart: unless-stopped
EOF

# Change directory to where docker-compose.yml is located and start the services
cd /home/ec2-user/workdir
# sudo docker-compose up -d
