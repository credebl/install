# CREDEBL Docker Deployment

This script contains the Docker-based deployment setup for the CREDEBL platform, providing a containerized solution for running all platform services.

## What It Does

The Docker deployment automates the complete setup of the CREDEBL platform using Docker containers. It orchestrates multiple microservices including:

### Core Services
- **API Gateway** - Central entry point for all API requests
- **User Service** - User management and authentication
- **Organization Service** - Organization management
- **Connection Service** - Manages connections between entities
- **Issuance Service** - Handles credential issuance
- **Verification Service** - Manages credential verification
- **Ledger Service** - Blockchain ledger interactions

### Supporting Services
- **PostgreSQL** - Primary database
- **Redis** - Caching and session management
- **NATS** - Message broker for microservice communication
- **Keycloak** - Identity and access management
- **Schema File Server** - Schema management and storage

### Additional Services
- **Agent Provisioning** - Agent creation
- **Agent Service** - Handles agent operations
- **Cloud Wallet** - Digital wallet functionality
- **Webhook Service** - Event notifications
- **Geolocation Service** - Location-based services
- **Notification Service** - System notifications
- **Ecosystem Service** - Ecosystem management
- **OID4VC Services** - OpenID for Verifiable Credentials support
- **X509 Service** - Certificate management

## Prerequisites

- Docker and Docker Compose
- Terraform (automatically installed by setup script)
- Node.js and npm/pnpm (automatically installed by setup script)
- AWS S3 credentials for file storage
- Email provider credentials (SendGrid, Resend, or SMTP)

## Quick Start

1. **Run the setup script:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Follow the interactive prompts to configure:**
   - Email provider (SendGrid/Resend/SMTP)
   - AWS S3 credentials for connection URLs (required)
   - AWS S3 credentials for bulk issuance (optional)
   - AWS S3 credentials for organization logos (optional)
   - PostgreSQL configuration (use existing or create new)
   - Admin user password

## Detailed Setup Process

### 1. Environment Configuration
The script automatically:
- Downloads environment templates from the main repository
- Detects available ports and configures services accordingly
- Prompts for required credentials and configurations
- Updates configuration files with your specific settings

### 2. Infrastructure Setup
- **Keycloak Deployment**: Starts Keycloak container for identity management
- **Terraform Configuration**: Sets up Keycloak realms, clients, and users
- **Database Setup**: Configures PostgreSQL (containerized or external)

### 3. Services
- **Core Services**: Launches all microservices with proper dependencies
- **Studio UI**: Builds and deploys the web interface

## Configuration Files

### docker-compose.yml
Defines all services and their dependencies:
- Service definitions with health checks
- Volume mounts for persistent data
- Port mappings for external access
- Environment variable injection

### .env
Contains all environment variables:
- Database connection strings
- Service endpoints and ports
- AWS credentials and bucket configurations
- Email provider settings
- Keycloak configuration
- Encryption keys and secrets

## Port Configuration

Default ports (automatically adjusted if unavailable):
- **Studio UI**: 3000
- **Schema File Server**: 4000
- **API Gateway**: 5000
- **PostgreSQL**: 5432
- **Redis**: 6379
- **Keycloak**: 8080
- **Agent**: 8001
- **Inbound Agent**: 9001

## Monitoring and Logs

- **Container Logs**: Access via `docker logs <container-name>`
- **Deployment Logs**: Comprehensive logging in `deployment.log`

## Accessing the Platform

After successful deployment:
- **Studio UI**: `http://<your-ip>:3000`
- **API Gateway**: `http://<your-ip>:5000/api`
- **Keycloak Admin**: `http://<your-ip>:8080` (admin/admin)

## Troubleshooting

### Common Issues
1. **Port Conflicts**: Script automatically finds available ports
2. **Docker Permissions**: Ensure user is in docker group
3. **Memory Issues**: Ensure sufficient RAM (minimum 8GB recommended)
4. **Network Issues**: Check firewall settings for required ports

### Logs and Debugging
- Check `deployment.log` for setup issues
- Use `docker logs <service-name>` for service-specific logs
- Verify service health with `docker ps`

## Cleanup

To stop and remove all services:
```bash
chmod +x destroy.sh
./destroy.sh
```

This will:
- Stop all running containers
- Remove containers and networks
- Preserve volumes (data) unless explicitly removed