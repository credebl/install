#!/bin/bash

set -euo pipefail

# Constants
LOG_FILE="deployment.log"
KEYCLOAK_VERSION="25.0.6"
TERRAFORM_DIR="../terraform-script/keycloak/"
ROOT_DIR="../../local-deployment/"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# Initialize logging
exec > >(tee -a "${LOG_FILE}") 2>&1
echo -e "\n\n=== Deployment started at $(date) ==="

# Cross-platform sed in-place function
sed_inplace() {
    if [ "$(uname)" == "Darwin" ]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    local symbol=""
    
    case "$color" in
        "green") symbol="✅" ;;
        "yellow") symbol="📁" ;;
        "red") symbol="❌" ;;
        "blue") symbol="🔍" ;;
        "purple") symbol="🛡️" ;;
        *) symbol="📌" ;;
    esac
    
    echo -e "${symbol} ${message}"
}

# Function to check command existence
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Prepare environment files
prepare_environment() {
    print_message "yellow" "Preparing environment files..."
    
    if [ ! -f .env ]; then
        print_message "yellow" "Copying .env.demo to .env..."
        cp .env.demo .env || {
            print_message "red" "Failed to copy .env.demo to .env"
            exit 1
        }
    else
        print_message "green" ".env already exists. Skipping copy."
    fi


    # Set default empty values for optional variables
    local AWS_ACCESS_KEY=${AWS_ACCESS_KEY:-}
    local AWS_SECRET_KEY=${AWS_SECRET_KEY:-}
    local AWS_REGION=${AWS_REGION:-}
    local AWS_BUCKET=${AWS_BUCKET:-}
    local AWS_PUBLIC_ACCESS_KEY=${AWS_PUBLIC_ACCESS_KEY:-}
    local AWS_PUBLIC_SECRET_KEY=${AWS_PUBLIC_SECRET_KEY:-}
    local AWS_PUBLIC_REGION=${AWS_PUBLIC_REGION:-}
    local AWS_ORG_LOGO_BUCKET_NAME=${AWS_ORG_LOGO_BUCKET_NAME:-}


    # Collect required variables
    read -p "Enter your machine IP address: " MACHINE_IP
    [[ -z "$MACHINE_IP" ]] && { print_message "red" "Machine IP cannot be empty"; exit 1; }

    read -p "Enter SendGrid API key: " SENDGRID_API_KEY
    [[ -z "$SENDGRID_API_KEY" ]] && { print_message "red" "SendGrid API key cannot be empty"; exit 1; }

    # Required S3 variables
    echo -e "\n# Required for storing connection URLs"
    read -p "Enter AWS S3 Access Key (required): " AWS_S3_STOREOBJECT_ACCESS_KEY
    read -p "Enter AWS S3 Secret Key (required): " AWS_S3_STOREOBJECT_SECRET_KEY
    read -p "Enter AWS S3 Region (required): " AWS_S3_STOREOBJECT_REGION
    read -p "Enter AWS S3 Bucket (required): " AWS_S3_STOREOBJECT_BUCKET

    # Validate required fields
    for var in AWS_S3_STOREOBJECT_ACCESS_KEY AWS_S3_STOREOBJECT_SECRET_KEY \
               AWS_S3_STOREOBJECT_REGION AWS_S3_STOREOBJECT_BUCKET; do
        if [[ -z "${!var}" ]]; then
            print_message "red" "$var is required"
            exit 1
        fi
    done

    # Optional variables
    echo -e "\n# Optional for Bulk Issuance (press Enter to skip)"
    read -p "Enter AWS Access Key (bulk): " AWS_ACCESS_KEY
    read -p "Enter AWS Secret Key (bulk): " AWS_SECRET_KEY
    read -p "Enter AWS Region (bulk): " AWS_REGION
    read -p "Enter AWS Bucket (bulk): " AWS_BUCKET

    echo -e "\n# Optional for Org Logos (press Enter to skip)"
    read -p "Enter AWS Public Access Key: " AWS_PUBLIC_ACCESS_KEY
    read -p "Enter AWS Public Secret Key: " AWS_PUBLIC_SECRET_KEY
    read -p "Enter AWS Public Region: " AWS_PUBLIC_REGION
    read -p "Enter AWS Org Logo Bucket: " AWS_ORG_LOGO_BUCKET_NAME

    # Update .env file
    sed_inplace "
        s|your-ip|$MACHINE_IP|g;
        s|sendgrid-apikey|$SENDGRID_API_KEY|g;
        /^# Used for storing connection URL/,/^$/ {
            s/^AWS_S3_STOREOBJECT_ACCESS_KEY=.*/AWS_S3_STOREOBJECT_ACCESS_KEY=${AWS_S3_STOREOBJECT_ACCESS_KEY}/;
            s/^AWS_S3_STOREOBJECT_SECRET_KEY=.*/AWS_S3_STOREOBJECT_SECRET_KEY=${AWS_S3_STOREOBJECT_SECRET_KEY}/;
            s/^AWS_S3_STOREOBJECT_REGION=.*/AWS_S3_STOREOBJECT_REGION=${AWS_S3_STOREOBJECT_REGION}/;
            s/^AWS_S3_STOREOBJECT_BUCKET=.*/AWS_S3_STOREOBJECT_BUCKET=${AWS_S3_STOREOBJECT_BUCKET}/;
        }
        /^# Used for Bulk issuance/,/^$/ {
            s/^AWS_ACCESS_KEY=.*/AWS_ACCESS_KEY=${AWS_ACCESS_KEY}/;
            s/^AWS_SECRET_KEY=.*/AWS_SECRET_KEY=${AWS_SECRET_KEY}/;
            s/^AWS_REGION=.*/AWS_REGION=${AWS_REGION}/;
            s/^AWS_BUCKET=.*/AWS_BUCKET=${AWS_BUCKET}/;
        }
        /^# Used for Adding org-logo/,/^$/ {
            s/^AWS_PUBLIC_ACCESS_KEY=.*/AWS_PUBLIC_ACCESS_KEY=${AWS_PUBLIC_ACCESS_KEY}/;
            s/^AWS_PUBLIC_SECRET_KEY=.*/AWS_PUBLIC_SECRET_KEY=${AWS_PUBLIC_SECRET_KEY}/;
            s/^AWS_PUBLIC_REGION=.*/AWS_PUBLIC_REGION=${AWS_PUBLIC_REGION}/;
            s/^AWS_ORG_LOGO_BUCKET_NAME=.*/AWS_ORG_LOGO_BUCKET_NAME=${AWS_ORG_LOGO_BUCKET_NAME}/;
        }
    " .env || {
        print_message "red" "Failed to update .env file"
        exit 1
    }

    print_message "green" "Environment file configured successfully."
}

# Step 2: Install Docker based on OS
install_docker() {
    local OS_ID
    if [ -f /etc/os-release ]; then
        OS_ID=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        OS_ID=$(uname -s)
    fi

    case "$OS_ID" in
        "ubuntu")
            install_docker_ubuntu
            ;;
        "debian")
            install_docker_debian
            ;;
        "Darwin")
            install_docker_macos
            ;;
        *)
            print_message "red" "Unsupported OS: $OS_ID"
            exit 1
            ;;
    esac
}

install_docker_ubuntu() {
    print_message "blue" "Detected Ubuntu. Checking Docker installation..."
    
    if ! command_exists docker || ! docker compose version &> /dev/null; then
        print_message "yellow" "Installing Docker on Ubuntu..."
        
        sudo apt-get update || {
            print_message "red" "Failed to update apt packages"
            exit 1
        }
        
        sudo apt-get install -y ca-certificates curl gnupg || {
            print_message "red" "Failed to install prerequisites"
            exit 1
        }
        
        sudo install -m 0755 -d /etc/apt/keyrings || {
            print_message "red" "Failed to create keyrings directory"
            exit 1
        }
        
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || {
            print_message "red" "Failed to download Docker GPG key"
            exit 1
        }
        
        sudo chmod a+r /etc/apt/keyrings/docker.asc || {
            print_message "red" "Failed to set keyring permissions"
            exit 1
        }
        
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || {
                print_message "red" "Failed to add Docker repository"
                exit 1
            }
        
        sudo apt-get update || {
            print_message "red" "Failed to update apt after adding Docker repo"
            exit 1
        }
        
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
            print_message "red" "Failed to install Docker packages"
            exit 1
        }
        
        print_message "green" "Docker installed successfully."
        sudo systemctl start docker || {
            print_message "red" "Failed to start Docker service"
            exit 1
        }
        sudo systemctl enable docker || {
            print_message "red" "Failed to enable Docker service"
            exit 1
        }
    else
        print_message "green" "Docker and Docker Compose are already installed."
    fi
}

install_docker_debian() {
    print_message "blue" "Detected Debian. Checking Docker installation..."
    
    if ! command_exists docker; then
        print_message "red" "Docker is not installed. Please install Docker manually on Debian."
        exit 1
    else
        print_message "green" "Docker is already installed."
    fi
    
    if ! docker compose version &> /dev/null; then
        print_message "red" "Docker Compose is not installed. Please install Docker Compose."
        exit 1
    else
        print_message "green" "Docker Compose is available."
    fi
}

install_docker_macos() {
    print_message "blue" "Detected macOS. Checking Docker installation..."
    
    if ! command_exists docker; then
        print_message "red" "Docker is not installed. Please install Docker Desktop for macOS. \
        You can refer to this URL: https://docs.docker.com/desktop/setup/install/mac-install/"
        exit 1
    else
        print_message "green" "Docker is already installed."
    fi
    
    if ! docker compose version &> /dev/null; then
        print_message "red" "Docker Compose is not installed. Please install Docker Compose."
        exit 1
    else
        print_message "green" "Docker Compose is available."
    fi
}

# Step 3: Install Terraform
install_terraform() {
    print_message "blue" "Checking Terraform installation..."
    
    if command_exists terraform; then
        print_message "green" "Terraform is already installed."
        return 0
    fi
    
    local OS_ID
    if [ -f /etc/os-release ]; then
        OS_ID=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        OS_ID=$(uname -s)
    fi

    case "$OS_ID" in
        "ubuntu"|"debian")
            install_terraform_linux
            ;;
        "Darwin")
            install_terraform_macos
            ;;
        *)
            print_message "red" "Unsupported OS for Terraform installation: $OS_ID"
            exit 1
            ;;
    esac
}

install_terraform_linux() {
    print_message "yellow" "Installing Terraform on Linux..."
    
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common || {
        print_message "red" "Failed to install prerequisites for Terraform"
        exit 1
    }
    
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null || {
        print_message "red" "Failed to add HashiCorp GPG key"
        exit 1
    }
    
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list || {
        print_message "red" "Failed to add HashiCorp repository"
        exit 1
    }
    
    sudo apt update || {
        print_message "red" "Failed to update apt after adding HashiCorp repo"
        exit 1
    }
    
    sudo apt-get install terraform || {
        print_message "red" "Failed to install Terraform"
        exit 1
    }
    
    print_message "green" "Terraform installed successfully."
}

install_terraform_macos() {
    print_message "yellow" "Installing Terraform on macOS..."
    
    if ! command_exists brew; then
        print_message "red" "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
    
    brew tap hashicorp/tap || {
        print_message "red" "Failed to tap hashicorp/tap"
        exit 1
    }
    
    brew install hashicorp/tap/terraform || {
        print_message "red" "Failed to install Terraform"
        exit 1
    }
    
    print_message "green" "Terraform installed successfully."
}

# Step 4: Deploy Keycloak
deploy_keycloak() {
    print_message "purple" "Setting up Keycloak..."
    
    if ! docker ps | grep -q "keycloak"; then
        print_message "purple" "Starting Keycloak container..."
        
        docker run -d -p 8080:8080 --name keycloak \
            -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin \
            quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} start-dev || {
                print_message "red" "Failed to start Keycloak container"
                exit 1
            }
            
        print_message "green" "Keycloak started successfully."
    else
        print_message "green" "Keycloak is already running."
    fi
}

# Step 5: Setup Keycloak using Terraform
setup_keycloak_terraform() {
    print_message "blue" "Setting up Keycloak via Terraform..."
    
    if [ ! -d "${TERRAFORM_DIR}" ]; then
        print_message "red" "Terraform directory not found: ${TERRAFORM_DIR}"
        exit 1
    fi
    
    cd "${TERRAFORM_DIR}" || {
        print_message "red" "Failed to change directory to ${TERRAFORM_DIR}"
        exit 1
    }
    
    terraform init || {
        print_message "red" "Terraform init failed"
        exit 1
    }
    
    print_message "yellow" "Waiting 30 seconds for Keycloak to be fully ready..."
    sleep 30
    
    terraform apply -auto-approve || {
        print_message "red" "Terraform apply failed"
        exit 1
    }
    
    print_message "green" "Keycloak setup completed via Terraform."
}

# Step 6: Update environment with Keycloak secret
update_keycloak_secret() {
    print_message "blue" "Updating environment with Keycloak secret..."
    
    if [ ! -f "secret.env" ]; then
        print_message "red" "secret.env not found! Could not insert KEYCLOAK_MANAGEMENT_CLIENT_SECRET."
        return 1
    fi
    
    SECRET=$(grep ADMIN_CLIENT_SECRET secret.env | cut -d '=' -f2)
    if [ -z "$SECRET" ]; then
        print_message "red" "Failed to extract ADMIN_CLIENT_SECRET from secret.env"
        return 1
    fi
    
    cd "${ROOT_DIR}" || {
        print_message "red" "Failed to change directory to ${ROOT_DIR}"
        exit 1
    }

    if grep -q "KEYCLOAK_MANAGEMENT_CLIENT_SECRET" .env; then
        sed_inplace "s/^KEYCLOAK_MANAGEMENT_CLIENT_SECRET=.*/KEYCLOAK_MANAGEMENT_CLIENT_SECRET=$SECRET/" .env || {
            print_message "red" "Failed to update existing KEYCLOAK_MANAGEMENT_CLIENT_SECRET in .env"
            return 1
        }
    else
        echo "KEYCLOAK_MANAGEMENT_CLIENT_SECRET=$SECRET" >> .env || {
            print_message "red" "Failed to append KEYCLOAK_MANAGEMENT_CLIENT_SECRET to .env"
            return 1
        }
    fi
    
    print_message "green" "Keycloak secret updated in .env successfully."
}

# Step 7: Pull credo-controller image
pull_credo_controller() {
    print_message "blue" "Pulling credo-controller image..."
    
    docker pull ghcr.io/credebl/credo-controller:latest || {
        print_message "red" "Failed to pull credo-controller image"
        exit 1
    }
    
    print_message "green" "credo-controller image pulled successfully."
}

# Step 8: Update master table configuration
update_master_table() {
    print_message "blue" "Updating master table configuration..."
    
    read -p "Enter the SendGrid sender email: " EMAIL_FROM
    
    if [ -z "$SENDGRID_API_KEY" ] || [ -z "$EMAIL_FROM" ]; then
        print_message "red" "SendGrid API key and sender email cannot be empty"
        exit 1
    fi
    
    sed_inplace "s|##Machine Ip Address/Domain for agent setup##|$MACHINE_IP|g" credebl-master-table.json || {
        print_message "red" "Failed to update machine IP in master table"
        exit 1
    }
    
    sed_inplace "s|## Platform API Ip Address##|http://$MACHINE_IP:5000|g" credebl-master-table.json || {
        print_message "red" "Failed to update platform API IP in master table"
        exit 1
    }
    
    sed_inplace "s|##Machine Ip Address for agent setup##|http://$MACHINE_IP:5000|g" credebl-master-table.json || {
        print_message "red" "Failed to update agent setup IP in master table"
        exit 1
    }
    
    sed_inplace "s|###Sendgrid Key###|$SENDGRID_API_KEY|g" credebl-master-table.json || {
        print_message "red" "Failed to update SendGrid key in master table"
        exit 1
    }
    
    sed_inplace "s|##Senders Mail ID##|$EMAIL_FROM|g" credebl-master-table.json || {
        print_message "red" "Failed to update sender email in master table"
        exit 1
    }
    
    print_message "green" "Master table configuration updated successfully."
}

# Step 9: Start Docker services
start_services() {
    print_message "blue" "Starting services with docker-compose..."
    
    if [ ! -f "${DOCKER_COMPOSE_FILE}" ]; then
        print_message "red" "Docker compose file not found: ${DOCKER_COMPOSE_FILE}"
        exit 1
    fi
    
    docker compose up -d || {
        print_message "red" "Failed to start services with docker-compose"
        exit 1
    }
    
    print_message "green" "Services started successfully."
}

# Main execution flow
main() {
    prepare_environment
    install_docker
    install_terraform
    deploy_keycloak
    setup_keycloak_terraform
    update_keycloak_secret
    pull_credo_controller
    update_master_table
    start_services
    
    print_message "green" "\n🎉 Deployment completed successfully!\n"
    echo "Check the logs for details: ${LOG_FILE}"
}

main