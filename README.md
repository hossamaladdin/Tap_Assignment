# AWS RDS SQL Server Infrastructure

This project provides Terraform configurations for deploying an AWS RDS SQL Server infrastructure across different environments (dev, staging, and prod).

## Overview

This infrastructure deploys:
- RDS SQL Server with environment-specific configurations
- VPC with public and private subnets across multiple availability zones
- NAT Gateways for private subnet connectivity
- Security groups and IAM roles
- Secrets management for database credentials
- CloudWatch logging and monitoring

## Prerequisites

- Terraform >= 1.0
- AWS CLI >= 2.0
- AWS Account with appropriate permissions

## Project Structure

```
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output definitions
├── versions.tf            # Provider versions
├── providers.tf           # Provider configuration
├── modules/              # Terraform modules
│   ├── vpc/             # Network infrastructure
│   ├── rds/             # Database infrastructure
│   ├── secrets/         # Credential management
│   └── iam/             # Access management
└── terraform.tfvars.example  # Example variables file
```

## Environment Configurations

Three environments are supported with different configurations:

### Development (dev)
- Instance Class: db.t3.large
- Storage: 100GB initial, max 200GB
- Multi-AZ: Disabled
- Backup Retention: 3 days
- Storage Type: gp3

### Staging
- Instance Class: db.m5.xlarge
- Storage: 200GB initial, max 500GB
- Multi-AZ: Enabled
- Backup Retention: 7 days
- Storage Type: gp3

### Production (prod)
- Instance Class: db.m5.2xlarge
- Storage: 500GB initial, max 1000GB
- Multi-AZ: Enabled
- Backup Retention: 14 days
- Storage Type: io1
- Enhanced security settings

## Deployment Instructions

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Plan Deployment** (choose environment)
   ```bash
   # Development
   terraform plan -var="environment=dev"

   # Staging
   terraform plan -var="environment=staging"

   # Production
   terraform plan -var="environment=prod"
   ```

3. **Apply Configuration**
   ```bash
   # Development
   terraform apply -var="environment=dev"

   # Staging
   terraform apply -var="environment=staging"

   # Production
   terraform apply -var="environment=prod"
   ```

4. **View Outputs**
   ```bash
   terraform output
   ```

## Outputs

- `rds_endpoint`: Database connection endpoint
- `rds_port`: Database port (1433)
- `db_secret_name`: Name of the secret in AWS Secrets Manager
- `db_secret_arn`: ARN of the secret in AWS Secrets Manager
- `vpc_id`: ID of the created VPC
- `private_subnet_ids`: List of private subnet IDs
- `public_subnet_ids`: List of public subnet IDs
- `rds_security_group_id`: ID of the RDS security group

## Security Features

- RDS instance deployed in private subnets
- Encryption at rest enabled
- Secure credential management using AWS Secrets Manager
- Security groups with minimal required access
- IAM roles following least privilege principle
- CloudWatch logging enabled