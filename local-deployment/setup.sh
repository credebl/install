#!/bin/bash

set -e
set -o pipefail

# REPO_URL="https://github.com/credebl/terraform-scripts.git"
REPO_DIR="terraform-scripts/local-deployment"

echo "Starting CREDEBL Platform Setup..."

# if [ ! -d "$REPO_DIR" ]; then
#     echo "cloning REPO"
#     git clone "$REPO_URL"
# fi

cd "$REPO_DIR"
git checkout refactor

# Step 1: Prepare environment files
if [ ! -f .env ]; then
    echo "📁 Copying .env.demo to .env..."
    cp .env.demo .env
else
    echo "✅ .env already exists. Skipping copy."
fi

read -p "Enter your machine IP address: " MACHINE_IP
sed -i "s|your-ip|$MACHINE_IP|g" .env

# Step 2: Check OS and install docker
OS_ID=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
OS_TYPE="$(uname -s)"
command_exists() {
  command -v "$1" &> /dev/null
}

if [ "$OS_ID" == "ubuntu" ]; then
    echo "Detected Ubuntu. Proceeding with Ubuntu-specific Docker installation."
    echo "🔍 Checking for Docker..."
    if ! command_exists docker; then
        echo "📦 Docker is not installed. Installing Docker..."
        sudo apt-get update
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update

        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        echo "✅ Docker installed."
        sudo systemctl start docker
        sudo systemctl enable docker
        fi
    else
    echo "✅ Docker is already installed."
    fi

    echo "🔍 Checking for Docker Compose..."
    if ! docker compose version &> /dev/null; then
        sudo apt-get install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update

        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        echo "✅ Docker Compose is available."
    fi

    echo "🛠️ Checking for Terraform..."
    if ! command -v terraform &> /dev/null; then
        echo "❌ Terraform is not installed. Installing Terraform..."
        
        # Install Terraform (Linux x86_64)
        sudo apt-get update
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
        wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update
        sudo apt-get install terraform
        echo "✅ Terraform installed."
    else
        echo "✅ Terraform is already installed."
    fi

elif [ "$OS_ID" == "debian" ]; then
    echo "Detected Debian."
    if ! command_exists docker; then
        echo "📦 Docker is not installed. Install Docker"
        exit 1
    else
    echo "✅ Docker is already installed."
    fi
    echo "🔍 Checking for Docker Compose..."
    if ! docker compose version &> /dev/null; then
        echo "📦 Docker compose is not installed. Install Docker compose..."
    else
        echo "✅ Docker Compose is available."
    fi
elif [ "$OS_TYPE" == "Darwin" ]; then
    echo "Detected Darwin. Install Docker and Docker Compose."
    if ! command_exists docker; then
        echo "📦 Docker is not installed. Install Docker and Docker compose..."
        exit 1
    else
    echo "✅ Docker is already installed."
    fi

    if ! docker compose version &> /dev/null; then
        echo "📦 Docker compose is not installed. Install Docker compose..."
    else
        echo "✅ Docker Compose is available."
    fi

    if ! command -v terraform &> /dev/null; then
        echo "❌ Terraform is not installed. Installing Terraform..."
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
        brew update
        brew upgrade hashicorp/tap/terraform
    else
        echo "✅ Terraform is already installed."
    fi
else
  echo "❌ Unsupported OS: $OS_ID"
  exit 1
fi

# Step 3: Deploy Keycloak
echo "🛡️ Setting up Keycloak..."
if ! docker ps | grep -q "keycloak"; then
    echo "🛡️ Starting Keycloak..."
    docker run -d -p 8080:8080 --name keycloak \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin \
        quay.io/keycloak/keycloak:25.0.6 start-dev
else
    echo "✅ Keycloak is already running."
fi

# Step 5: Setup Keycloak using Terraform
echo "🔐 Setting up Keycloak via Terraform..."
cd ../terraform-script/keycloak/
terraform init
sleep 30
terraform apply -auto-approve

# Step 6: Insert ADMIN_CLIENT_SECRET into .env
if [ -f secret.env ]; then
    echo "🔑 Extracting ADMIN_CLIENT_SECRET and adding to .env..."
    SECRET=$(grep ADMIN_CLIENT_SECRET secret.env | cut -d '=' -f2)

    # If it already exists, replace it. Else, append.
    if grep -q "KEYCLOAK_MANAGEMENT_CLIENT_SECRET" ../.env; then
        sed -i "s/^KEYCLOAK_MANAGEMENT_CLIENT_SECRET=.*/KEYCLOAK_MANAGEMENT_CLIENT_SECRET=$SECRET/" ../.env
    else
        echo "KEYCLOAK_MANAGEMENT_CLIENT_SECRET=$SECRET" >> ../.env
    fi

    echo "✅ Secret inserted in .env"
else
    echo "secret.env not found! Could not insert KEYCLOAK_MANAGEMENT_CLIENT_SECRET."
fi
cd ../../local-deployment/
# Step 7: Pull credo-controller image
echo "Pulling credo-controller image from GHCR..."
docker pull ghcr.io/credebl/credo-controller:latest

# Step 8: Credebl master table data
read -s -p "Enter your SendGrid API key: " SENDGRID_API_KEY
read -p "Enter the SendGrid sender email: " EMAIL_FROM

## Replace in credebl-master-table.json
sed -i "s|##Machine Ip Address/Domain for agent setup##|$MACHINE_IP|g" credebl-master-table.json
sed -i "s|## Platform API Ip Address##|http://$MACHINE_IP:5000|g" credebl-master-table.json
sed -i "s|##Machine Ip Address for agent setup##|http://$MACHINE_IP:5000|g" credebl-master-table.json
sed -i "s|###Sendgrid Key###|$SENDGRID_API_KEY|g" credebl-master-table.json
sed -i "s|##Senders Mail ID##|$EMAIL_FROM|g" credebl-master-table.json

# Step 9: Start Docker services
echo "🚀 Starting services with docker-compose..."
docker compose up -d
