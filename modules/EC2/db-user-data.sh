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
version: "3.4"
services:
  mediator:
    image: postgres:latest
    command: postgres -c 'max_connections=500'
    volumes:
      - ./mediator-volume/volumes/postgres-data:/postgres/postgres-data:z
      - ./mediator-volume/volumes/postgres-data-backup:/var/lib/postgresql/data
    ports:
      - "${db_port}:${db_port}"
    healthcheck:
      test: [ "CMD", "pg_isready", "-q", "-d", "${db_name}", "-U", "${db_user}" ]
      timeout: 45s
      interval: 10s
      retries: 10
    restart: always
    environment:
      - POSTGRES_USER=${db_user}
      - POSTGRES_PASSWORD=${db_password}
      - POSTGRES_DB=${db_name}
volumes:
  mediator:
    driver: local
EOF

# Change directory to where docker-compose.yml is located and start the services
cd /home/ec2-user/workdir
sudo docker-compose up -d
