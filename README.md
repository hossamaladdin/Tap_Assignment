# AWS RDS SQL Server Infrastructure

Terraform Infrastructure as Code project for provisioning high-availability RDS SQL Server on AWS.

## Overview

This project deploys:
- Multi-AZ RDS SQL Server for high availability
- VPC with private subnets across multiple availability zones
- Secure credential management using AWS Secrets Manager
- CloudWatch monitoring and Performance Insights
- IAM roles with least privilege
- Environment configurations (dev, staging, prod)

## Components

- **VPC Module**: Network with private subnets across multiple AZs
- **RDS Module**: Multi-AZ SQL Server with parameter/option groups
- **Secrets Module**: Database credential management
- **IAM Module**: Monitoring and access roles

## Prerequisites

- Terraform >= 1.0
- AWS CLI >= 2.0
- AWS Account with appropriate permissions

### AWS Permissions Required
- VPC and networking resources
- RDS instance management
- Secrets Manager
- IAM roles and policies
- CloudWatch
- EC2 (if using bastion host)

## Quick Start

1. **Clone Repository**
   ```bash
   git clone https://github.com/hossamaladdin/Tap_Assignment.git
   cd Tap_Assignment
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Deploy Infrastructure**
   ```bash
   # For development environment
   terraform apply -var-file=environments/dev.tfvars

   # For staging environment
   terraform apply -var-file=environments/staging.tfvars

   # For production environment
   terraform apply -var-file=environments/prod.tfvars
   ```

4. **Get Outputs**
   ```bash
   terraform output
   ```

## Project Structure

```
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Provider versions
├── providers.tf            # Provider configuration
├── environments/           # Environment configs
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── modules/                # Terraform modules
│   ├── vpc/               # Network infrastructure
│   ├── rds/               # Database infrastructure
│   ├── secrets/           # Credential management
│   └── iam/               # Access management
└── scripts/               # Helper scripts
    ├── connect_to_rds.sh  # Database connection
    ├── setup.sh           # Project setup
    └── update_secret.sh   # Secret management
```

## Configuration

### Environment Files
Each environment file contains configuration for instance sizing, storage, backups, and security settings.

### Key Variables
- `environment`: Environment name (dev/staging/prod)
- `rds_instance_class`: RDS instance size
- `rds_allocated_storage`: Initial storage in GB
- `rds_backup_retention_period`: Backup retention days
- `allowed_cidr_blocks`: IP ranges for database access

## Connecting to RDS

Use the connection script:
```bash
./scripts/connect_to_rds.sh <rds-endpoint>
```

Or connect manually:
- **Server**: RDS endpoint (from terraform output)
- **Authentication**: SQL Server Authentication
- **Username**: sqladmin
- **Password**: Retrieved from AWS Secrets Manager

## Security

- Database runs in private subnets
- Encryption at rest enabled
- Credentials stored in AWS Secrets Manager
- Security groups restrict access
- IAM roles follow least privilege

## Monitoring

- CloudWatch logs for SQL Server error and agent logs
- Performance Insights for query-level monitoring
- Enhanced monitoring at 60-second intervals

## Environment Sizing

- **Development**: db.t3.large, 100GB, 3-day backups
- **Staging**: db.m5.xlarge, 200GB, 7-day backups
- **Production**: db.m5.2xlarge, 500GB, 14-day backups

## Cost Optimization

### Environment-Specific Sizing

| Environment | Instance Class | Storage | Multi-AZ | Estimated Monthly Cost* |
|-------------|---------------|---------|----------|------------------------|
| Dev | db.t3.large | 100 GB | No | ~$300-400 |
| Staging | db.m5.xlarge | 200 GB | Yes | ~$1,200-1,500 |
| Production | db.m5.2xlarge | 500 GB | Yes | ~$2,500-3,000 |

*Estimates are approximate and vary by region

### Cost-Saving Tips

1. **Use Reserved Instances** for production (up to 60% savings)
2. **Enable Storage Autoscaling** to avoid over-provisioning
3. **Optimize Backup Retention** based on requirements
4. **Use gp3 storage** instead of gp2 or io1 where appropriate
5. **Disable bastion host** when not needed

## Authors

- **Hossam Aladdin** - *Initial work* - [hossamaladdin](https://github.com/hossamaladdin)
