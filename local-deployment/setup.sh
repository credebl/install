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

prompt_yes_no() {
  local prompt_message=$1
  local response

  while true; do
    read -p "$prompt_message (yes/no): " response
    case "$response" in
      yes|y) return 0 ;;
      no|n) return 1 ;;
      *) echo "Please enter only 'yes' or 'no'." ;;
    esac
  done
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
        print_message "green" ".env already exists. Skipping copy and checking existing values..."
    fi

    escape_sed() {
        echo "$1" | sed -e 's/[\/&]/\\&/g'
    }

    handle_existing_value() {
        local var_name=$1
        local prompt=$2
        local required=${3:-true}  # Default to true if not specified
        local current_value=$(grep "^$var_name=" .env | cut -d'=' -f2-)
        
        # Check for existing value
        if [ -n "$current_value" ]; then
            if prompt_yes_no "Found existing $var_name=$current_value. Continue with this value?"; then
                eval "$var_name=\"$current_value\""
                print_message "green" "Using existing $var_name"
                return
            else
                print_message "yellow" "Will prompt for new $var_name value"
                unset current_value
            fi
        fi
        
        # Input loop
        while true; do
            read -p "$prompt: " $var_name
            if [ "$required" = "true" ] && [ -z "${!var_name}" ]; then
                print_message "red" "Value cannot be empty"
            else
                break
            fi
        done
    }

    # Collect required variables
    MACHINE_IP=$(ipconfig getifaddr en0 2>/dev/null || ip route get 1 | awk '{print $7; exit}')

    handle_existing_value "SENDGRID_API_KEY" "Enter SendGrid API key"
    handle_existing_value "EMAIL_FROM" "Enter SendGrid sender email"

    # Required S3 variables
    echo -e "\n# Provide S3 credentials, required for storing connection URLs"
    handle_existing_value "AWS_S3_STOREOBJECT_ACCESS_KEY" "Enter AWS S3 Access Key"
    handle_existing_value "AWS_S3_STOREOBJECT_SECRET_KEY" "Enter AWS S3 Secret Key"
    handle_existing_value "AWS_S3_STOREOBJECT_REGION" "Enter AWS S3 Region"
    handle_existing_value "AWS_S3_STOREOBJECT_BUCKET" "Enter AWS S3 Bucket"

    # bulk issuance
    if prompt_yes_no "Do you want to use bulk issuance?"; then
        echo -e "\n# Provide S3 credentials for bulk issuance"
        handle_existing_value "AWS_ACCESS_KEY" "Enter AWS Access Key (bulk)"
        handle_existing_value "AWS_SECRET_KEY" "Enter AWS Secret Key (bulk)"
        handle_existing_value "AWS_REGION" "Enter AWS Region (bulk)"
        handle_existing_value "AWS_BUCKET" "Enter AWS Bucket (bulk)"
    fi

    # Optional org logos
    if prompt_yes_no "Do you want to upload org logos?"; then
        echo -e "\n# Provide S3 credentials for org logos"
        handle_existing_value "AWS_PUBLIC_ACCESS_KEY" "Enter AWS Public Access Key"
        handle_existing_value "AWS_PUBLIC_SECRET_KEY" "Enter AWS Public Secret Key"
        handle_existing_value "AWS_PUBLIC_REGION" "Enter AWS Public Region"
        handle_existing_value "AWS_ORG_LOGO_BUCKET_NAME" "Enter AWS Org Logo Bucket"
    fi
    
    sed_inplace "
        s|your-ip|$(escape_sed "$MACHINE_IP")|g;
        s|^SENDGRID_API_KEY=.*|SENDGRID_API_KEY=$(escape_sed "$SENDGRID_API_KEY")|;
        /^# Used for storing connection URL/,/^$/ {
            s|^AWS_S3_STOREOBJECT_ACCESS_KEY=.*|AWS_S3_STOREOBJECT_ACCESS_KEY=$(escape_sed "$AWS_S3_STOREOBJECT_ACCESS_KEY")|;
            s|^AWS_S3_STOREOBJECT_SECRET_KEY=.*|AWS_S3_STOREOBJECT_SECRET_KEY=$(escape_sed "$AWS_S3_STOREOBJECT_SECRET_KEY")|;
            s|^AWS_S3_STOREOBJECT_REGION=.*|AWS_S3_STOREOBJECT_REGION=$(escape_sed "$AWS_S3_STOREOBJECT_REGION")|;
            s|^AWS_S3_STOREOBJECT_BUCKET=.*|AWS_S3_STOREOBJECT_BUCKET=$(escape_sed "$AWS_S3_STOREOBJECT_BUCKET")|;
        }
        /^# Used for Bulk issuance/,/^$/ {
            s|^AWS_ACCESS_KEY=.*|AWS_ACCESS_KEY=$(escape_sed "$AWS_ACCESS_KEY")|;
            s|^AWS_SECRET_KEY=.*|AWS_SECRET_KEY=$(escape_sed "$AWS_SECRET_KEY")|;
            s|^AWS_REGION=.*|AWS_REGION=$(escape_sed "$AWS_REGION")|;
            s|^AWS_BUCKET=.*|AWS_BUCKET=$(escape_sed "$AWS_BUCKET")|;
        }
        /^# Used for Adding org-logo/,/^$/ {
            s|^AWS_PUBLIC_ACCESS_KEY=.*|AWS_PUBLIC_ACCESS_KEY=$(escape_sed "$AWS_PUBLIC_ACCESS_KEY")|;
            s|^AWS_PUBLIC_SECRET_KEY=.*|AWS_PUBLIC_SECRET_KEY=$(escape_sed "$AWS_PUBLIC_SECRET_KEY")|;
            s|^AWS_PUBLIC_REGION=.*|AWS_PUBLIC_REGION=$(escape_sed "$AWS_PUBLIC_REGION")|;
            s|^AWS_ORG_LOGO_BUCKET_NAME=.*|AWS_ORG_LOGO_BUCKET_NAME=$(escape_sed "$AWS_ORG_LOGO_BUCKET_NAME")|;
        }
        s|^SHORTENED_URL_DOMAIN=.*|SHORTENED_URL_DOMAIN=https://s3.$(escape_sed "$AWS_S3_STOREOBJECT_REGION").amazonaws.com/$(escape_sed "$AWS_S3_STOREOBJECT_BUCKET")|;
    " .env || {
        print_message "red" "Failed to update .env file"
        exit 1
    }
    sed_inplace "s|your-ip|$(escape_sed "$MACHINE_IP")|g" agent.env
    print_message "green" "Environment file configured successfully."
}

# Step 2: Check  ports availability, docker and node, if not available installs node
declare -A PORTS=(
    ["postgres"]=5432
    ["api-gateway"]=5000
    ["redis"]=6379
    ["keycloak"]=8080
    ["schema-file-server"]=4000
)

# Function to check if port is available
is_port_available() {
    local port=$1
    
    # Method 1: Try netcat first (most reliable)
    if command -v nc &>/dev/null; then
        if nc -z 127.0.0.1 "$port" &>/dev/null; then
            return 1 # Port is in use
        else
            return 0 # Port is available
        fi
    fi
    
    # Method 2: macOS fallback using lsof
    if [[ "$OSTYPE" == "darwin"* ]] && command -v lsof &>/dev/null; then
        if lsof -i :"$port" -sTCP:LISTEN &>/dev/null; then
            return 1
        else
            return 0
        fi
    fi
    
    # Method 3: Linux /dev/tcp check (bash builtin)
    if (echo >/dev/tcp/127.0.0.1/"$port") &>/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

# Function to find first available port from list
find_available_port() {
    local base_port=$1
    local max_attempts=10
    local current_port=$base_port
    
    for (( i=0; i<max_attempts; i++ )); do
        if is_port_available "$current_port"; then
            echo "$current_port"
            return 0
        fi
        ((current_port++))
    done
    
    print_message "red" "Could not find available port after $max_attempts attempts (base: $base_port)"
    exit 1
}

# Check and assign ports
configure_ports() {
    declare -gA USED_PORTS  # Will store the final port assignments

    for service in "${!PORTS[@]}"; do
        base_port="${PORTS[$service]}"
        available_port=$(find_available_port "$base_port")
        
        USED_PORTS["$service"]="$available_port"
        print_message "green" "Assigned port $available_port for $service"
    done

    # Update .env file with selected ports
    update_ports_config
}

update_ports_config() {
    sed_inplace "
        s|5432|${USED_PORTS["postgres"]}|g;
        s|5000|${USED_PORTS["api-gateway"]}|g;
        s|6379|${USED_PORTS["redis"]}|g;
        s|8080|${USED_PORTS["keycloak"]}|g;
        s|4000|${USED_PORTS["schema-file-server"]}|g;
    " .env
    sed_inplace "
        s|5432:5432|${USED_PORTS["postgres"]}:5432|;
        s|5000:5000|${USED_PORTS["api-gateway"]}:5000|;
        s|6379:6379|${USED_PORTS["redis"]}:6379|;
        s|4000:4000|${USED_PORTS["schema-file-server"]}:4000|;
    " docker-compose.yml

    print_message "green" "Updated .env file and docker-compose available ports"
}

install_nodejs() {
    # Check and install Node.js if needed
    if ! command_exists -v node &> /dev/null; then
        print_message "yellow" "Node.js not found. Installing..."
        
        if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
            # Linux installation
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y nodejs || {
                print_message "red" "Failed to install Node.js"
                exit 1
            }
        elif [[ "$OS_ID" == "Darwin" ]]; then
            # macOS installation
            if ! command_exists -v brew &> /dev/null; then
                print_message "red" "Homebrew required but not found. Install via: https://brew.sh"
                exit 1
            fi
            brew install node || {
                print_message "red" "Failed to install Node.js"
                exit 1
            }
        else
            print_message "red" "Unsupported OS for Node.js installation"
            exit 1
        fi
        print_message "green" "Node.js installed successfully"
    else
        print_message "green" "Node.js already installed"
    fi
}

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
        
        docker run -d -p ${USED_PORTS["keycloak"]}:8080 --name keycloak \
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

# Step 6: Update environment with Keycloak secret and JWT_token
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

generate_jwt_secret() {
    print_message "blue" "Generating JWT secret..."
    
    install_nodejs
    
    # Generate secure random secret
    local JWT_TOKEN_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))" 2>/dev/null)
    
    if [[ -z "$JWT_TOKEN_SECRET" ]]; then
        print_message "red" "Failed to generate JWT secret"
        exit 1
    fi

    # Update .env file
    sed_inplace "s/^JWT_TOKEN_SECRET=.*/JWT_TOKEN_SECRET=$JWT_TOKEN_SECRET/" .env || {
        print_message "red" "Failed to update JWT secret in .env"
        exit 1
    }

    print_message "green" "JWT secret generated and stored successfully"
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
    sleep 30
    print_message "yellow" "Waiting 30 seconds for Services to be fully ready..."
    print_message "green" "Services started successfully."
}

# Step 10: Update env file
update_env() {
    print_message "blue" "Updating environment with Schema File Server details..."
    
    # Wait for schema-file-server to start and get auth token
    local SCHEMA_FILE_SERVER_TOKEN
    local FILE_SERVER_TOKEN
    SCHEMA_FILE_SERVER_TOKEN=$(docker logs schema-file-server 2>&1 | grep "Auth Token:" | awk '{print $3}' | head -n 1)
    
    if [[ -z "$SCHEMA_FILE_SERVER_TOKEN" ]]; then
        print_message "red" "Failed to get Schema File Server auth token"
        exit 1
    fi

    # Update .env file
    sed_inplace "
        s/^SCHEMA_FILE_SERVER_TOKEN=.*/SCHEMA_FILE_SERVER_TOKEN=${SCHEMA_FILE_SERVER_TOKEN}/;
    " .env || {
        print_message "red" "Failed to update Schema File Server configuration in .env"
        exit 1
    }

    sed_inplace "
        s/^FILE_SERVER_TOKEN=.*/FILE_SERVER_TOKEN=${SCHEMA_FILE_SERVER_TOKEN}/;
    " agent.env || {
        print_message "red" "Failed to update Schema File Server configuration in agent.env"
        exit 1
    }

    chmod +x $PWD/apps/schemas
    print_message "green" "Schema File Server configuration updated successfully:"
}

# Main execution flow
main() {
    prepare_environment
    configure_ports
    install_docker
    install_terraform
    deploy_keycloak
    setup_keycloak_terraform
    update_keycloak_secret
    generate_jwt_secret
    pull_credo_controller
    update_master_table
    start_services
    update_env
    
    print_message "green" "\n🎉 Deployment completed successfully!\n"
    echo "Check the logs for details: ${LOG_FILE}"
}

main