# AWS RDS SQL Server High-Availability Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-RDS-FF9900?logo=amazon-aws)](https://aws.amazon.com/rds/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A production-ready Terraform Infrastructure as Code (IaC) project for provisioning a high-availability RDS SQL Server cluster on AWS with comprehensive security, monitoring, and best practices.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Connecting to RDS](#connecting-to-rds)
- [Monitoring](#monitoring)
- [Security](#security)
- [Cost Optimization](#cost-optimization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🎯 Overview

This project provides a complete Infrastructure as Code solution for deploying a highly available RDS SQL Server instance on AWS. It includes:

- **Multi-AZ RDS SQL Server** for high availability
- **VPC with public and private subnets** across multiple availability zones
- **Secure credential management** using AWS Secrets Manager
- **Enhanced monitoring** with CloudWatch and Performance Insights
- **Optional bastion host** for secure database access
- **IAM roles and policies** following the principle of least privilege
- **Environment-specific configurations** (dev, staging, prod)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS Cloud                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                      │  │
│  │                                                            │  │
│  │  ┌──────────────────┐        ┌──────────────────┐        │  │
│  │  │  Public Subnet   │        │  Public Subnet   │        │  │
│  │  │   (AZ-1a)        │        │   (AZ-1b)        │        │  │
│  │  │                  │        │                  │        │  │
│  │  │  ┌────────────┐  │        │  ┌────────────┐  │        │  │
│  │  │  │  Bastion   │  │        │  │ NAT Gateway│  │        │  │
│  │  │  │   Host     │  │        │  └────────────┘  │        │  │
│  │  │  └────────────┘  │        │                  │        │  │
│  │  └──────────────────┘        └──────────────────┘        │  │
│  │           │                           │                   │  │
│  │           │                           │                   │  │
│  │  ┌────────▼───────────┐      ┌───────▼──────────┐        │  │
│  │  │  Private Subnet    │      │  Private Subnet  │        │  │
│  │  │   (AZ-1a)          │      │   (AZ-1b)        │        │  │
│  │  │                    │      │                  │        │  │
│  │  │  ┌──────────────┐  │      │  ┌──────────────┐│        │  │
│  │  │  │ RDS Primary  │◄─┼──────┼─►│ RDS Standby  ││        │  │
│  │  │  │ SQL Server   │  │      │  │ SQL Server   ││        │  │
│  │  │  └──────────────┘  │      │  └──────────────┘│        │  │
│  │  └────────────────────┘      └──────────────────┘        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌────────────────────┐    ┌──────────────────┐                │
│  │  Secrets Manager   │    │   CloudWatch     │                │
│  │  (DB Credentials)  │    │   (Monitoring)   │                │
│  └────────────────────┘    └──────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

1. **VPC Module**: Creates isolated network with public/private subnets across multiple AZs
2. **RDS Module**: Provisions Multi-AZ SQL Server instance with parameter/option groups
3. **Secrets Manager Module**: Securely stores and manages database credentials
4. **IAM Module**: Creates roles and policies for RDS monitoring and Secrets Manager access
5. **Bastion Module**: Optional EC2 instance for secure database access

## ✨ Features

### High Availability
- ✅ Multi-AZ deployment for automatic failover
- ✅ Automated backups with configurable retention
- ✅ Maintenance window management

### Security
- ✅ Encrypted storage at rest
- ✅ Secure credential management with Secrets Manager
- ✅ Network isolation with VPC and security groups
- ✅ IAM roles with least privilege principle
- ✅ VPC Flow Logs for network monitoring

### Monitoring
- ✅ CloudWatch alarms for CPU, memory, storage, and connections
- ✅ Performance Insights enabled
- ✅ Enhanced monitoring (60-second intervals)
- ✅ CloudWatch Logs integration (error and agent logs)

### Scalability
- ✅ Storage autoscaling
- ✅ Easy instance class modifications
- ✅ Read replica support (can be added)

### Cost Optimization
- ✅ Environment-specific configurations
- ✅ gp3 storage for better price/performance
- ✅ Configurable backup retention
- ✅ Optional bastion host

## 📋 Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0
- AWS Account with appropriate permissions

### AWS Permissions Required
- VPC and networking resources
- RDS instance management
- Secrets Manager
- IAM roles and policies
- CloudWatch
- EC2 (if using bastion host)

### AWS CLI Configuration
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region name: us-east-1
# Default output format: json
```

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/hossamaladdin/Tap_Assignment.git
cd Tap_Assignment
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review and Customize Configuration
Edit the environment-specific configuration file:
```bash
# For development environment
cp environments/dev.tfvars terraform.tfvars
vim terraform.tfvars
```

**Important**: Update these values in `terraform.tfvars`:
- `aws_region`: Your preferred AWS region
- `allowed_cidr_blocks`: Your IP ranges for database access
- `bastion_key_name`: Your SSH key name (if using bastion)
- `bastion_allowed_cidr_blocks`: Your IP ranges for SSH access

### 4. Plan the Deployment
```bash
terraform plan -var-file=environments/dev.tfvars
```

### 5. Deploy the Infrastructure
```bash
terraform apply -var-file=environments/dev.tfvars
```

### 6. Retrieve Outputs
```bash
terraform output
```

## 📁 Project Structure

```
.
├── README.md                      # This file
├── versions.tf                    # Terraform and provider versions
├── providers.tf                   # AWS provider configuration
├── variables.tf                   # Root module variables
├── main.tf                        # Main resource definitions
├── outputs.tf                     # Output values
├── environments/                  # Environment-specific configurations
│   ├── dev.tfvars                # Development environment
│   ├── staging.tfvars            # Staging environment
│   └── prod.tfvars               # Production environment
├── modules/                       # Reusable Terraform modules
│   ├── vpc/                      # VPC and networking
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/                      # RDS SQL Server
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── secrets/                  # Secrets Manager
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/                      # IAM roles and policies
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── bastion/                  # Bastion host (optional)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── scripts/                       # Helper scripts
│   ├── connect_to_rds.sh         # Database connection script
│   └── update_secret.sh          # Update Secrets Manager
└── docs/                          # Additional documentation
    ├── ARCHITECTURE.md
    ├── SECURITY.md
    └── OPERATIONS.md
```

## ⚙️ Configuration

### Environment Variables

The project supports three environments: **dev**, **staging**, and **prod**. Each environment has its own configuration file in the `environments/` directory.

#### Key Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `environment` | Environment name (dev/staging/prod) | `dev` |
| `rds_instance_class` | RDS instance type | `db.t3.large` |
| `rds_multi_az` | Enable Multi-AZ deployment | `true` |
| `rds_allocated_storage` | Initial storage in GB | `100` |
| `rds_backup_retention_period` | Backup retention in days | `7` |
| `rds_deletion_protection` | Enable deletion protection | `true` |
| `enable_bastion` | Deploy bastion host | `false` |

### Backend Configuration

For production use, configure remote state storage in `versions.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "rds-sqlserver/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

## 🚢 Deployment

### Development Environment
```bash
terraform apply -var-file=environments/dev.tfvars
```

### Staging Environment
```bash
terraform apply -var-file=environments/staging.tfvars
```

### Production Environment
```bash
terraform apply -var-file=environments/prod.tfvars
```

### Targeted Resource Deployment
```bash
# Deploy only VPC
terraform apply -target=module.vpc -var-file=environments/dev.tfvars

# Deploy only RDS
terraform apply -target=module.rds -var-file=environments/dev.tfvars
```

## 🔌 Connecting to RDS

### Method 1: Using Bastion Host (Recommended)

If you enabled the bastion host:

1. **SSH to Bastion Host**
```bash
ssh -i ~/.ssh/your-key.pem ec2-user@<bastion-public-ip>
```

2. **Connect to RDS**
```bash
./connect_to_rds.sh <rds-endpoint>
```

The script automatically:
- Retrieves credentials from Secrets Manager
- Connects to SQL Server using sqlcmd

### Method 2: Direct Connection (VPN/DirectConnect)

If you have VPN or Direct Connect:

1. **Get RDS Endpoint**
```bash
terraform output rds_endpoint
```

2. **Retrieve Credentials**
```bash
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw db_secret_name) \
  --query SecretString \
  --output text | jq -r '.password'
```

3. **Connect using SQL Server Management Studio (SSMS)**
- Server name: `<rds-endpoint>`
- Authentication: SQL Server Authentication
- Login: `sqladmin` (or your configured username)
- Password: (from Secrets Manager)

### Method 3: Using AWS Systems Manager Session Manager

For bastion host without SSH keys:

```bash
aws ssm start-session --target <bastion-instance-id>
```

## 📊 Monitoring

### CloudWatch Alarms

The following alarms are automatically created:

1. **CPU Utilization**: Alert when > 80%
2. **Freeable Memory**: Alert when < 1GB
3. **Free Storage Space**: Alert when < 10GB
4. **Database Connections**: Alert when > 100

### Performance Insights

Enabled by default with 7-day retention (31 days in production).

Access via AWS Console: RDS → Your Instance → Performance Insights

### CloudWatch Logs

Two log streams are exported:
- **Error logs**: SQL Server errors
- **Agent logs**: SQL Server Agent logs

### View Logs
```bash
# List log groups
aws logs describe-log-groups --log-group-name-prefix /aws/rds

# View recent logs
aws logs tail /aws/rds/instance/<instance-name>/error --follow
```

## 🔒 Security

### Network Security
- Private subnets for RDS (no internet access)
- Security groups with minimal required rules
- VPC Flow Logs for network monitoring

### Data Security
- Encryption at rest using AWS KMS
- Encryption in transit (TLS/SSL)
- Automated backups encrypted

### Access Control
- IAM roles with least privilege
- Secrets Manager for credential management
- No hardcoded credentials
- Optional bastion host for controlled access

### Compliance
- Deletion protection enabled in production
- Backup retention configurable
- Audit logging available via CloudWatch

### Best Practices Implemented
✅ No public accessibility
✅ Multi-AZ for high availability
✅ Automated backups
✅ Enhanced monitoring
✅ Parameter and option groups
✅ Security group rules

## 💰 Cost Optimization

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
6. **Schedule RDS stop/start** for dev environments (non-production)

### Monitor Costs
```bash
# Get cost estimate
aws ce get-cost-and-usage \
  --time-period Start=2025-10-01,End=2025-10-31 \
  --granularity MONTHLY \
  --metrics "BlendedCost" \
  --filter file://cost-filter.json
```

## 🔧 Troubleshooting

### Common Issues

#### Issue: Terraform Init Fails
```bash
# Clear cache and reinitialize
rm -rf .terraform
rm .terraform.lock.hcl
terraform init
```

#### Issue: RDS Creation Fails
- Check AWS service quotas for RDS instances
- Verify subnet groups span multiple AZs
- Ensure security groups allow required traffic

#### Issue: Cannot Connect to RDS
```bash
# Verify security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Test network connectivity from bastion
nc -zv <rds-endpoint> 1433

# Check RDS status
aws rds describe-db-instances --db-instance-identifier <instance-id>
```

#### Issue: Secrets Manager Access Denied
```bash
# Verify IAM role has correct permissions
aws iam get-role-policy --role-name <role-name> --policy-name <policy-name>

# Test secret retrieval
aws secretsmanager get-secret-value --secret-id <secret-name>
```

### Debug Mode
```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
terraform apply -var-file=environments/dev.tfvars
```

### Getting Help
- Check [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- Review [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Open an issue on GitHub

## 🔄 Updating the Infrastructure

### Apply Changes
```bash
# Review changes
terraform plan -var-file=environments/prod.tfvars

# Apply changes
terraform apply -var-file=environments/prod.tfvars
```

### Modify RDS Instance
```bash
# Update instance class
terraform apply -var="rds_instance_class=db.m5.xlarge" -var-file=environments/prod.tfvars
```

### Update Database Parameters
Edit `modules/rds/main.tf` parameter group and apply changes.

## 🧹 Cleanup

### Destroy Infrastructure
```bash
# Development
terraform destroy -var-file=environments/dev.tfvars

# Production (requires deletion protection to be disabled)
terraform destroy -var-file=environments/prod.tfvars
```

**Warning**: This will permanently delete all resources including databases and backups (unless final snapshot is enabled).

## 📚 Additional Resources

- [AWS RDS for SQL Server](https://aws.amazon.com/rds/sqlserver/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Best Practices for RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html)
- [SQL Server on AWS](https://aws.amazon.com/sql-server/)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Hossam Aladdin** - *Initial work* - [hossamaladdin](https://github.com/hossamaladdin)

## 🙏 Acknowledgments

- AWS Documentation Team
- Terraform Community
- HashiCorp

---

**Note**: This is a demonstration project for the Tap Database Consultant Assignment. Always review and test thoroughly before using in production environments.

For questions or support, please open an issue on GitHub.