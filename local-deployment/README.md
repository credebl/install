# CREDEBL Local Development Deployment

This directory contains the local development setup for the CREDEBL platform, providing a native development environment where services run directly on your machine rather than in containers.

## What It Does

The local deployment sets up a complete CREDEBL development environment by:

### Platform Setup
- **Source Code Management**: Clones the latest CREDEBL platform repository
- **Branch/Tag Selection**: Allows deployment of specific branches or tagged releases
- **Dependency Installation**: Installs all required development dependencies
- **Environment Configuration**: Sets up all necessary environment variables and configurations

### Infrastructure Services (Containerized)
- **PostgreSQL**: Database server (containerized or external)
- **Redis**: Caching and session management (containerized)
- **NATS**: Message broker for microservice communication (containerized)
- **Keycloak**: Identity and access management (containerized)
- **Schema File Server**: Schema management (containerized)

### Application Services (Native)
All CREDEBL microservices run natively using Node.js:
- **API Gateway** - Central routing and authentication
- **User Service** - User management and profiles
- **Utility Service** - Common utilities and helpers
- **Connection Service** - Entity connection management
- **Ledger Service** - Blockchain ledger operations
- **Organization Service** - Organization lifecycle management
- **Agent Provisioning** - Dynamic agent creation and management
- **Agent Service** - Agent operations and communication
- **Issuance Service** - Credential issuance workflows
- **Verification Service** - Credential verification processes
- **Webhook Service** - Event-driven notifications
- **Geolocation Service** - Location-based functionality
- **Cloud Wallet Service** - Digital wallet operations
- **Ecosystem Service** - Ecosystem management
- **Notification Service** - System-wide notifications
- **OID4VC Services** - OpenID for Verifiable Credentials
- **X509 Service** - Certificate management

## Prerequisites

### System Requirements
- **Operating System**: Linux (Ubuntu/Debian) or macOS
- **Memory**: Minimum 8GB RAM (16GB recommended)
- **Storage**: At least 10GB free space
- **Network**: Internet connection for dependencies and external services

### Required Software (Auto-installed)
- **Node.js** (v18+) and npm/pnpm
- **Docker** and Docker Compose (for infrastructure services)
- **Terraform** (for Keycloak configuration)
- **PostgreSQL Client** (psql)
- **Git** (for source code management)

### External Dependencies
- **AWS S3 Account**: For file storage and connection URLs
- **Email Provider**: SendGrid, Resend, or SMTP server

## Quick Start

1. **Run the setup script:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Select deployment type:**
   - Choose between specific tag or branch deployment
   - Enter the tag name or branch name when prompted

3. **Configure the environment:**
   - Email provider credentials
   - AWS S3 settings for connection URLs (required)
   - Bulk issuance S3 settings (optional)
   - Organization logo S3 settings (optional)
   - PostgreSQL configuration
   - Keycloak database settings

## Detailed Setup Process

### 1. Source Code Preparation
- **Repository Cloning**: Downloads the CREDEBL platform source code
- **Version Selection**: Checks out specified branch or tag
- **Dependency Installation**: Runs `pnpm install` to install all Node.js dependencies
- **Environment Setup**: Copies and configures environment files

### 2. Infrastructure Deployment
- **Port Detection**: Automatically finds available ports for all services
- **Database Setup**: 
  - Option 1: Containerized PostgreSQL with automatic setup
  - Option 2: External PostgreSQL with custom configuration
- **Keycloak Database**: Separate database for identity management
- **Redis & NATS**: Containerized message broker and caching
- **Keycloak Container**: Identity provider with custom configuration

### 3. Identity Management Setup
- **Terraform Initialization**: Sets up Keycloak infrastructure as code
- **Realm Configuration**: Creates CREDEBL realm with proper settings

### 4. Database Initialization
- **Schema Migration**: Runs Prisma migrations to set up database schema
- **Seed Data**: Populates initial data using master table configuration
- **Master Table Updates**: Configures platform-specific settings and credentials

### 5. Service Configuration
- **Environment Variables**: Updates all service configurations with actual values
- **Schema Service**: Configures schema file server with authentication tokens

### 6. Development Environment Launch
- **Linux**: Opens multiple terminal tabs for each service
- **macOS**: Provides manual startup instructions (due to terminal limitations)

## Configuration Files

### Platform Directory Structure
```
platform/
├── apps/                    # Microservice applications
├── libs/                    # Shared libraries
├── .env                     # Main environment configuration
├── agent.env               # Agent-specific configuration
├── docker-compose.*.yml    # Infrastructure service definitions
├── package.json            # Node.js dependencies
└── prisma/                 # Database schema and migrations
```

### Key Configuration Files
- **.env**: Main application configuration with all service settings
- **agent.env**: Agent provisioning and communication settings
- **keycloak.env**: Keycloak container configuration
- **docker-compose.postgres.yml**: PostgreSQL container setup
- **docker-compose.redis.yml**: Redis container configuration
- **docker-compose.nats.yml**: NATS message broker setup

## Development Workflow

### Starting Services (Linux)
The setup script automatically opens terminal tabs for each service:
1. API Gateway starts first
2. Core services (User, Utility, Connection, Ledger, Organization) start next
4. Agent services start after provisioning is ready
5. Other services (Webhook, Notification, etc.) start last

### Starting Services (macOS)
Manual startup required due to terminal limitations:
```bash
cd platform
pnpm run start                    # API Gateway
pnpm run start user              # User Service
pnpm run start utility           # Utility Service
pnpm run start connection        # Connection Service
# ... continue with other services
```

### Service Dependencies
Services must start in order due to dependencies:
1. **API Gateway** - Must start first
2. **User Service and Organization service** - Required by most other services
3. **Utility and Ledger Service** - Provides common functionality
4. **Agent Provisioning** - Must be ready before Agent Service
5. **Other Services** - Can start in parallel after core services

## Monitoring and Debugging

### Service Logs
Each service runs in its own terminal/process:
- **Real-time Logs**: Live log streaming for each service
- **Log Levels**: Configurable logging levels (debug, info, warn, error)
- **Structured Logging**: JSON-formatted logs for better parsing

## Troubleshooting

### Common Issues

1. **Port Conflicts**
   - Script automatically detects and assigns available ports
   - Check `netstat -tulpn` to see port usage

2. **Database Connection Issues**
   - Verify PostgreSQL is running: `docker ps`
   - Check connection string in `.env` file
   - Ensure database exists and is accessible

3. **Service Startup Failures**
   - Check individual service logs for error details
   - Verify all dependencies are installed: `pnpm install`
   - Ensure proper startup order (API Gateway first)

4. **Keycloak Configuration Issues**
   - Verify Terraform setup completed successfully
   - Check Keycloak admin console: `http://localhost:8080`
   - Validate client secrets in environment files

## Cleanup and Reset

### Stop All Services
- **Linux**: Close all terminal tabs or use Ctrl+C in each tab
- **macOS**: Stop each service manually with Ctrl+C

### Reset Environment
```bash
# Stop containers
docker compose -f docker-compose.postgres.yml down
docker compose -f docker-compose.redis.yml down
docker compose -f docker-compose.nats.yml down
docker stop credebl-keycloak

# Clean up (optional)
docker system prune -f
rm -rf platform/            # Remove cloned repository
```

This local deployment provides a complete development environment that closely mirrors production while offering the flexibility and debugging capabilities needed for effective development.