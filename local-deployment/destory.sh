#!/bin/bash

set -euo pipefail

# Initialize logging
LOG_FILE="Cleanup.log"
exec > >(tee -a "${LOG_FILE}") 2>&1
echo -e "\n\n=== Targeted Cleanup started at $(date) ==="

# Function definitions
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

# 1. Stop and remove specific containers
cleanup_containers() {
    print_message "blue" "Cleaning up application containers..."
    
    # List of containers created by setup.sh
    local containers=("keycloak" "credo-controller")
    
    for container in "${containers[@]}"; do
        if docker ps -a --format '{{.Names}}' | grep -q "^${container}\$"; then
            docker stop "$container" >/dev/null 2>&1 && \
                docker rm -f "$container" >/dev/null 2>&1 && \
                print_message "green" "Removed container: $container" || \
                print_message "red" "Failed to remove container: $container"
        else
            print_message "green" "Container not found: $container"
        fi
    done
    
    # Remove containers created by docker (using the compose project name)
    if [ -f "docker-compose.yml" ]; then
        print_message "blue" "Removing docker containers..."
        docker compose down --volumes --remove-orphans && \
            print_message "green" "docker containers removed" || \
            print_message "yellow" "No docker containers found"
    fi
}

# 2. Clean up specific images
cleanup_images() {
    print_message "blue" "Cleaning up application images..."
    
    # Check if docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        print_message "yellow" "docker-compose.yml not found, skipping image cleanup"
        return
    fi

    # Extract image names from docker-compose.yml
    local images=($(grep '^[[:space:]]*image:' docker-compose.yml | awk '{print $2}' | sort | uniq))
    
    # Add any additional images not in docker-compose.yml
    images+=(
        "quay.io/keycloak/keycloak:25.0.6",
        "ghcr.io/credebl/credo-controller:latest"
    )

    if [ ${#images[@]} -eq 0 ]; then
        print_message "yellow" "No images found in docker-compose.yml"
        return
    fi

    print_message "blue" "Found images to remove:"
    printf ' - %s\n' "${images[@]}"

    for image in "${images[@]}"; do
        if docker image inspect "$image" >/dev/null 2>&1; then
            docker rmi -f "$image" && \
                print_message "green" "Removed image: $image" || \
                print_message "red" "Failed to remove image: $image"
        else
            print_message "yellow" "Image not found: $image"
        fi
    done

    # Clean up dangling images
    print_message "blue" "Cleaning up dangling images..."
    docker image prune -f && \
        print_message "green" "Dangling images removed" || \
        print_message "yellow" "No dangling images found"
}

# 3. Clean up Terraform resources
cleanup_terraform() {
    print_message "blue" "Cleaning up Terraform resources..."
    
    local terraform_dir="../terraform-script/keycloak/"
    
    if [ -d "${terraform_dir}" ]; then
        cd "${terraform_dir}" || {
            print_message "red" "Could not enter Terraform directory"
            return 1
        }
        
        if [ -f "terraform.tfstate" ]; then
            terraform destroy -auto-approve && \
                print_message "green" "Terraform resources destroyed" || \
                print_message "red" "Terraform destroy failed"
        else
            print_message "yellow" "No Terraform state found, skipping"
        fi
        
        cd - >/dev/null || {
            print_message "red" "Could not return to original directory"
            return 1
        }
    else
        print_message "yellow" "Terraform directory not found, skipping"
    fi
}

# 4. Clean up environment files (optional)
cleanup_files() {
    print_message "blue" "Cleaning up environment files..."
    
    # Remove secret.env if exists
    if [ -f "secret.env" ]; then
        rm -f secret.env && \
            print_message "green" "Removed secret.env" || \
            print_message "yellow" "Failed to remove secret.env"
    fi
    
    # Keep .env file but you can add removal here if needed
    print_message "green" "Preserved .env file (modify cleanup_files() if you want to remove it)"
}

# Main execution
main() {
    print_message "purple" "Starting teardown..."
    
    cleanup_containers
    cleanup_images
    cleanup_terraform
    cleanup_files
    
    print_message "green" "\n🎉 Targeted cleanup completed successfully!"
}

main