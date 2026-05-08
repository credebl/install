# CREDEBL AWS Terraform Infrastructure

This directory contains Terraform Infrastructure as Code (IaC) for deploying the complete CREDEBL platform on Amazon Web Services (AWS) using containerized microservices architecture.

## What It Does

The AWS Terraform configuration automates the deployment of a production-ready, scalable CREDEBL platform with the following components:

### Infrastructure Components

#### **Networking Infrastructure**
- **VPC (Virtual Private Cloud)**: Isolated network environment with custom CIDR blocks
- **Subnets**: Multi-AZ deployment with public, private app, and private database subnets
- **Internet Gateway**: Provides internet access to public subnets
- **NAT Gateway**: Enables outbound internet access for private subnets
- **Route Tables**: Proper routing configuration for all subnet tiers
- **Security Groups**: Fine-grained network access control for each service

#### **Compute Infrastructure**
- **ECS Cluster**: Managed container orchestration platform
- **ECS Services**: Auto-scaling microservices with health checks
- **Task Definitions**: Container specifications for each CREDEBL service
- **Application Load Balancer (ALB)**: HTTP/HTTPS traffic distribution
- **Network Load Balancer (NLB)**: TCP traffic for NATS messaging
- **Target Groups**: Health monitoring and traffic routing

#### **Storage Infrastructure**
- **EFS (Elastic File System)**: Shared storage for NATS clustering and agent configurations
- **S3 Buckets**: Environment files and application data storage
- **EBS Volumes**: Container persistent storage (managed by ECS)

#### **Security & Access Management**
- **IAM Roles**: Service-specific permissions for ECS tasks
- **IAM Policies**: Least-privilege access to AWS resources
- **Security Groups**: Network-level security controls
- **SSL/TLS Certificates**: HTTPS encryption via ACM

#### **Monitoring & Logging**
- **CloudWatch Log Groups**: Centralized logging for all services
- **ECS Service Connect**: Internal service communication


## Prerequisites

### AWS Requirements
- **AWS Account**: Active AWS account with appropriate permissions
- **AWS CLI**: Configured with credentials and default region
- **Terraform**: Version >= 0.13 installed locally
- **Domain & SSL**: Valid domain name and SSL certificate in ACM

### Required AWS Permissions
Your AWS credentials must have permissions for:
- **VPC Management**: Create/modify VPCs, subnets, gateways, route tables
- **ECS Management**: Create clusters, services, task definitions
- **Load Balancer Management**: Create/configure ALB and NLB
- **IAM Management**: Create roles and policies for services
- **S3 Management**: Create and manage S3 buckets
- **EFS Management**: Create and configure file systems
- **CloudWatch Management**: Create log groups and metrics
- **Security Group Management**: Create and modify security groups

### Network Requirements
- **Available CIDR Block**: Non-overlapping CIDR for VPC (default: 10.0.0.0/16)
- **Multi-AZ Deployment**: Minimum 2 availability zones in target region
- **Internet Connectivity**: For pulling container images and external API calls

## Configuration Files

### Core Configuration Files

#### `main.tf`
The main orchestration file that defines all modules and their relationships:
```hcl
# Root module for common configurations
module "root" { ... }

# VPC and networking infrastructure
module "vpc" { ... }

# Security groups for network access control
module "security_groups" { ... }

# IAM roles and policies
module "iam" { ... }

# S3 buckets for storage
module "s3" { ... }

# EFS for shared storage
module "efs" { ... }

# Application Load Balancer
module "alb" { ... }

# Network Load Balancer for NATS
module "nlb" { ... }

# CloudWatch logging
module "cloudwatch_group" { ... }

# ECS cluster and services
module "ecs" { ... }
```

#### `variables.tf`
Defines all configurable parameters:
```hcl
# AWS Configuration
variable "profile" {}        # AWS profile name
variable "project_name" {}   # Project identifier
variable "environment" {}    # Environment (PROD/DEV/STAGING)
variable "region" {}         # AWS region

# SSL and Domain
variable "certificate_arn" {} # ACM certificate ARN
variable "domain_name" {}     # Domain for the platform

# Network Configuration
variable "vpc_cidr" {}                    # VPC CIDR block
variable "public_subnet_cidr" {}          # Public subnet CIDRs
variable "private_app_subnet_cidr" {}     # Private app subnet CIDRs
variable "private_db_subnet_cidr" {}      # Private DB subnet CIDRs

# Service Configuration
variable "natscluster" {}     # Enable NATS clustering
variable "image_tag" {}       # Container image tag
```

#### `terraform.tfvars`
Contains actual configuration values:
```hcl
# AWS Configuration
region       = "us-west-2"
project_name = "CREDEBL"
environment  = "PROD"
profile      = "your-aws-profile"

# SSL Configuration
certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/abcd1234-..."
domain_name     = "your-domain.com"

# Network Configuration
vpc_cidr                = "10.0.0.0/16"
public_subnet_cidr      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_app_subnet_cidr = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
private_db_subnet_cidr  = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

# Service Configuration
natscluster = true
image_tag   = "latest"
```

#### `provider.tf`
Configures Terraform providers:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6"
    }
  }
  required_version = ">= 0.13"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}
```

#### `backend.tf`
Configures remote state storage:
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "credebl/terraform.tfstate"
    region = "us-west-2"
  }
}
```

## Module Architecture

### Infrastructure Modules

#### **VPC Module** (`modules/vpc/`)
Creates complete networking infrastructure:
- **VPC**: Main virtual private cloud
- **Internet Gateway**: Public internet access
- **NAT Gateway**: Private subnet internet access
- **Subnets**: Public, private app, and private database subnets
- **Route Tables**: Routing configuration for all subnets
- **Availability Zones**: Multi-AZ deployment for high availability

#### **Security Groups Module** (`modules/security_group/`)
Defines network access controls:
- **ALB Security Group**: HTTP/HTTPS access (ports 80, 443)
- **App Security Groups**: Service-specific access controls
- **NATS Security Group**: Message broker communication (ports 4222, 6222, 8222)
- **EFS Security Group**: File system access (port 2049)
- **Redis Security Group**: Cache access (port 6379)
- **Database Security Group**: PostgreSQL access (port 5432)

#### **IAM Module** (`modules/iam/`)
Creates service roles and policies:
- **ECS Task Execution Role**: Container lifecycle management
- **ECS Task Role**: Application-specific AWS permissions
- **S3 Access Policies**: Bucket access for environment files
- **CloudWatch Policies**: Logging and monitoring permissions

#### **S3 Module** (`modules/s3/`)
Creates storage buckets:
- **Environment Files Bucket**: Secure storage for .env files
- **Application Data Bucket**: Platform-specific file storage
- **Backup Bucket**: Configuration and data backups

#### **EFS Module** (`modules/efs/`)
Creates shared file systems:
- **NATS EFS**: Shared storage for NATS clustering
- **Agent EFS**: Shared storage for agent configurations
- **Seed EFS**: Database initialization files

#### **Load Balancer Modules** (`modules/alb/`, `modules/nlb/`)
Creates traffic distribution:
- **Application Load Balancer**: HTTP/HTTPS traffic routing
- **Network Load Balancer**: TCP traffic for NATS
- **Target Groups**: Health checks and service routing
- **SSL Termination**: HTTPS encryption handling

#### **CloudWatch Module** (`modules/cloudwatch/`)
Creates monitoring infrastructure:
- **Log Groups**: Service-specific log collection
- **Metrics**: Performance and health monitoring
- **Alarms**: Automated alerting (optional)

#### **ECS Module** (`modules/ecs/`)
Creates container orchestration:
- **ECS Cluster**: Container management platform
- **Task Definitions**: Container specifications
- **ECS Services**: Auto-scaling service management
- **Service Discovery**: Internal service communication

## Service Configuration

### Service Categories

#### **Services with Load Balancer**
Services exposed through the Application Load Balancer:

1. **API Gateway** (Port 5000)
   - Health check: `/api`
   - Database connection required

2. **Keycloak** (Port 8080)
   - Identity and access management
   - Health check: `/documentation.html`
   - Database connection required

3. **UI/Studio** (Port 3000)
   - Web-based user interface
   - Health check: `/auth/sign-in`

## Deployment Instructions

### Step 1: Deployment Steps

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Validate Configuration**:
   ```bash
   terraform validate
   ```

3. **Plan Deployment**:
   ```bash
   terraform plan
   ```

4. **Apply Configuration**:
   ```bash
   terraform apply
   ```

5. **Confirm Deployment**:
   Type `yes` when prompted to confirm the deployment.

---
## Using Existing VPC

If you want to use an existing VPC instead of creating a new one, follow these steps:

### Prerequisites for Existing VPC

Ensure your existing VPC has:
- **VPC ID**: The existing VPC identifier
- **Public Subnets**: At least 2 public subnets in different AZs
- **Private Subnets**: At least 2 private subnets in different AZs
- **Internet Gateway**: Attached to VPC for public subnet internet access
- **NAT Gateway/Instance**: For private subnet internet access (recommended)
- **Route Tables**: Properly configured for public and private subnets

### Step 1: Gather VPC Information

Collect the following information:
```bash
# Get VPC details
VPC_ID="vpc-xxxxxxxxx"
VPC_CIDR="10.0.0.0/16"
PUBLIC_SUBNET_1="subnet-xxxxxxxxx"
PUBLIC_SUBNET_2="subnet-yyyyyyyyy"
PRIVATE_SUBNET_1="subnet-zzzzzzzzz"
PRIVATE_SUBNET_2="subnet-aaaaaaaaa"
```

### Step 2: Modify Terraform Configuration

1. **Backup Current Configuration**:
   ```bash
   cp main.tf main.tf.backup
   cp variable.tf variable.tf.backup
   cp terraform.tfvars terraform.tfvars.backup
   ```

2. **Comment Out VPC Module**:
   Edit `main.tf` and comment out the VPC module:
   ```hcl
   # Comment out the entire VPC module
   # module "vpc" {
   #   source                  = "../modules/vpc"
   #   project_name            = var.project_name
   #   environment             = var.environment
   #   vpc_cidr                = var.vpc_cidr
   #   public_subnet_cidr      = var.public_subnet_cidr
   #   private_app_subnet_cidr = var.private_app_subnet_cidr
   #   private_db_subnet_cidr  = var.private_db_subnet_cidr
   #   aws_region              = var.region
   # }
   ```

3. **Add Data Sources**:
   Add these data sources after the `module "root"` block in `main.tf`:
   ```hcl
   # Data sources for existing VPC
   data "aws_vpc" "existing" {
     id = var.existing_vpc_id
   }
   
   data "aws_subnets" "existing_public" {
     filter {
       name   = "vpc-id"
       values = [var.existing_vpc_id]
     }
     
     filter {
       name   = "subnet-id"
       values = var.existing_public_subnet_ids
     }
   }
   
   data "aws_subnets" "existing_private" {
     filter {
       name   = "vpc-id"
       values = [var.existing_vpc_id]
     }
     
     filter {
       name   = "subnet-id"
       values = var.existing_private_subnet_ids
     }
   }
   
   # Local values to maintain compatibility
   locals {
     vpc_id                 = data.aws_vpc.existing.id
     vpc_cidr              = data.aws_vpc.existing.cidr_block
     public_subnet_ids     = var.existing_public_subnet_ids
     private_app_subnet_ids = var.existing_private_subnet_ids
   }
   ```

4. **Update Module References**:
   Replace all `module.vpc.*` references with `local.*` values in these modules:
   
   **Security Groups Module**:
   ```hcl
   module "security_groups" {
     # ... other parameters ...
     vpc_id   = local.vpc_id      # Changed from module.vpc.vpc_id
     vpc_cidr = local.vpc_cidr    # Changed from module.vpc.vpc_cidr
     # ... rest of configuration ...
   }
   ```
   
   **EFS Module**:
   ```hcl
   module "efs" {
     # ... other parameters ...
     vpc_id                 = local.vpc_id                    # Changed
     private_app_subnet_ids = local.private_app_subnet_ids   # Changed
     # ... rest of configuration ...
   }
   ```
   
   **ALB Module**:
   ```hcl
   module "alb" {
     # ... other parameters ...
     vpc_id            = local.vpc_id              # Changed
     public_subnet_ids = local.public_subnet_ids  # Changed
     # ... rest of configuration ...
   }
   ```
   
   **NLB Module**:
   ```hcl
   module "nlb" {
     # ... other parameters ...
     public_subnet_ids = local.public_subnet_ids  # Changed
     vpc_id           = local.vpc_id              # Changed
     # ... rest of configuration ...
   }
   ```
   
   **ECS Module**:
   ```hcl
   module "ecs" {
     # ... other parameters ...
     vpc_id                 = local.vpc_id                    # Changed
     public_subnet_ids      = local.public_subnet_ids        # Changed
     private_app_subnet_ids = local.private_app_subnet_ids   # Changed
     # ... rest of configuration ...
   }
   ```

### Step 3: Add New Variables

Add these variables to `variable.tf`:
```hcl
# Existing VPC Configuration
variable "existing_vpc_id" {
  description = "ID of the existing VPC to use"
  type        = string
  default     = ""
}

variable "existing_public_subnet_ids" {
  description = "List of existing public subnet IDs"
  type        = list(string)
  default     = []
}

variable "existing_private_subnet_ids" {
  description = "List of existing private subnet IDs (for app tier)"
  type        = list(string)
  default     = []
}

variable "use_existing_vpc" {
  description = "Whether to use existing VPC or create new one"
  type        = bool
  default     = false
}
```

### Step 4: Update terraform.tfvars

Add your existing VPC configuration:
```hcl
# Existing VPC Configuration
use_existing_vpc = true
existing_vpc_id = "vpc-xxxxxxxxx"
existing_public_subnet_ids = [
  "subnet-xxxxxxxxx",  # Public subnet in AZ-1
  "subnet-yyyyyyyyy"   # Public subnet in AZ-2
]
existing_private_subnet_ids = [
  "subnet-zzzzzzzzz",  # Private subnet in AZ-1
  "subnet-aaaaaaaaa"   # Private subnet in AZ-2
]

# Keep existing VPC CIDR for reference
vpc_cidr = "10.0.0.0/16"  # Your existing VPC CIDR
```

### Step 5: Deploy with Existing VPC

1. **Validate Configuration**:
   ```bash
   terraform validate
   ```

2. **Plan Deployment**:
   ```bash
   terraform plan
   ```

3. **Apply Changes**:
   ```bash
   terraform apply
   ```

## Monitoring and Maintenance

### CloudWatch Monitoring

1. Service Logs:

2. ECS Service Health:

3. Load Balancer Health:


### Backup and Recovery

**State Backup**:
   ```bash
   # Download current state
   terraform state pull > terraform.tfstate.backup
   ```

## Troubleshooting

### Common Issues

1. **Certificate Issues**:
   - Verify certificate exists and is valid

2. **Service Startup Failures**:
   - Check Service logs

3. **Network Connectivity Issues**:
   - Check security group rules
   - Verify route tables

4. **Load Balancer Issues**:
   - Check ALB status
   - Check target group health

This comprehensive infrastructure setup provides a production-ready and secure foundation for the CREDEBL platform on AWS.