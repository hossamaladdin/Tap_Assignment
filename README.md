# AWS RDS SQL Server Infrastructure# AWS RDS SQL Server Infrastructure



Terraform project for provisioning high-availability RDS SQL Server on AWS.Terraform Infrastructure as Code project for provisioning a high-availability RDS SQL Server on AWS.



## Overview## Overview



This project deploys:This project deploys:

- Multi-AZ RDS SQL Server for high availability

- VPC with private subnets across multiple availability zones- **Multi-AZ RDS SQL Server** for high availability

- Secure credential management using AWS Secrets Manager- **VPC with private subnets** across multiple availability zones

- CloudWatch monitoring and Performance Insights- **Secure credential management** using AWS Secrets Manager

- IAM roles with least privilege- **CloudWatch monitoring** and Performance Insights

- Environment configurations (dev, staging, prod)- **IAM roles and policies** with least privilege

- **Environment configurations** (dev, staging, prod)

## Components

## Components

- **VPC Module**: Network with private subnets across multiple AZs

- **RDS Module**: Multi-AZ SQL Server with parameter/option groups- **VPC Module**: Network with private subnets across multiple AZs

- **Secrets Module**: Database credential management  - **RDS Module**: Multi-AZ SQL Server with parameter/option groups

- **IAM Module**: Monitoring and access roles- **Secrets Module**: Database credential management

- **IAM Module**: Monitoring and access roles

## Prerequisites

## Features

- Terraform >= 1.0

- AWS CLI >= 2.0- Multi-AZ deployment for high availability

- AWS Account with appropriate permissions- Encrypted storage and secure credentials

- CloudWatch monitoring and Performance Insights

## Quick Start- Environment-specific configurations (dev/staging/prod)

- Storage autoscaling

1. **Clone Repository**

   ```bash## 📋 Prerequisites

   git clone https://github.com/hossamaladdin/Tap_Assignment.git

   cd Tap_Assignment### Required Tools

   ```- [Terraform](https://www.terraform.io/downloads.html) >= 1.0

- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0

2. **Initialize Terraform**- AWS Account with appropriate permissions

   ```bash

   terraform init### AWS Permissions Required

   ```- VPC and networking resources

- RDS instance management

3. **Deploy Infrastructure**- Secrets Manager

   ```bash- IAM roles and policies

   # For development environment- CloudWatch

   terraform apply -var-file=environments/dev.tfvars- EC2 (if using bastion host)

   

   # For staging environment  ### AWS CLI Configuration

   terraform apply -var-file=environments/staging.tfvars```bash

   aws configure

   # For production environment# Enter your AWS Access Key ID

   terraform apply -var-file=environments/prod.tfvars# Enter your AWS Secret Access Key

   ```# Default region name: us-east-1

# Default output format: json

4. **Get Outputs**```

   ```bash

   terraform output## 🚀 Quick Start

   ```

### 1. Clone the Repository

## Project Structure```bash

git clone https://github.com/hossamaladdin/Tap_Assignment.git

```cd Tap_Assignment

├── main.tf                 # Main configuration```

├── variables.tf            # Input variables

├── outputs.tf              # Output values### 2. Initialize Terraform

├── versions.tf             # Provider versions```bash

├── providers.tf            # Provider configurationterraform init

├── environments/           # Environment configs```

│   ├── dev.tfvars

│   ├── staging.tfvars### 3. Review and Customize Configuration

│   └── prod.tfvarsEdit the environment-specific configuration file:

├── modules/                # Terraform modules```bash

│   ├── vpc/               # Network infrastructure# For development environment

│   ├── rds/               # Database infrastructurecp environments/dev.tfvars terraform.tfvars

│   ├── secrets/           # Credential managementvim terraform.tfvars

│   └── iam/               # Access management```

└── scripts/               # Helper scripts

    ├── connect_to_rds.sh  # Database connection**Important**: Update these values in `terraform.tfvars`:

    ├── setup.sh           # Project setup- `aws_region`: Your preferred AWS region

    └── update_secret.sh   # Secret management- `allowed_cidr_blocks`: Your IP ranges for database access

```- `bastion_key_name`: Your SSH key name (if using bastion)

- `bastion_allowed_cidr_blocks`: Your IP ranges for SSH access

## Configuration

### 4. Plan the Deployment

### Environment Files```bash

terraform plan -var-file=environments/dev.tfvars

Each environment file (`environments/*.tfvars`) contains configuration for:```

- Instance sizing

- Storage allocation### 5. Deploy the Infrastructure

- Backup retention```bash

- Network settingsterraform apply -var-file=environments/dev.tfvars

- Security configurations```



### Key Variables### 6. Retrieve Outputs

```bash

- `environment`: Environment name (dev/staging/prod)terraform output

- `rds_instance_class`: RDS instance size```

- `rds_allocated_storage`: Initial storage in GB

- `rds_backup_retention_period`: Backup retention days## 📁 Project Structure

- `allowed_cidr_blocks`: IP ranges for database access

```

## Connecting to RDS.

├── README.md                      # This file

Use the included connection script:├── versions.tf                    # Terraform and provider versions

```bash├── providers.tf                   # AWS provider configuration

./scripts/connect_to_rds.sh <rds-endpoint>├── variables.tf                   # Root module variables

```├── main.tf                        # Main resource definitions

├── outputs.tf                     # Output values

Or manually with SQL Server tools:├── environments/                  # Environment-specific configurations

- **Server**: RDS endpoint (from terraform output)│   ├── dev.tfvars                # Development environment

- **Authentication**: SQL Server Authentication│   ├── staging.tfvars            # Staging environment

- **Username**: sqladmin (or configured username)│   └── prod.tfvars               # Production environment

- **Password**: Retrieved from AWS Secrets Manager├── modules/                       # Reusable Terraform modules

│   ├── vpc/                      # VPC and networking

## Outputs│   │   ├── main.tf

│   │   ├── variables.tf

The deployment provides:│   │   └── outputs.tf

- `rds_endpoint`: Database connection endpoint│   ├── rds/                      # RDS SQL Server

- `rds_master_username`: Master username│   │   ├── main.tf

- `db_secret_arn`: Secrets Manager ARN for credentials│   │   ├── variables.tf

- `rds_instance_id`: RDS instance identifier│   │   └── outputs.tf

│   ├── secrets/                  # Secrets Manager

## Monitoring│   │   ├── main.tf

│   │   ├── variables.tf

- CloudWatch logs are enabled for SQL Server error and agent logs│   │   └── outputs.tf

- Performance Insights provides query-level monitoring│   ├── iam/                      # IAM roles and policies

- Enhanced monitoring available at 60-second intervals│   │   ├── main.tf

│   │   ├── variables.tf

## Security│   │   └── outputs.tf

│   └── bastion/                  # Bastion host (optional)

- Database runs in private subnets│       ├── main.tf

- Encryption at rest enabled│       ├── variables.tf

- Credentials stored in AWS Secrets Manager│       └── outputs.tf

- Security groups restrict access├── scripts/                       # Helper scripts

- IAM roles follow least privilege│   ├── connect_to_rds.sh         # Database connection script

│   └── update_secret.sh          # Update Secrets Manager

## Cost Optimization└── docs/                          # Additional documentation

    ├── ARCHITECTURE.md

Environment-specific sizing:    ├── SECURITY.md

- **Development**: db.t3.large, 100GB, 3-day backups    └── OPERATIONS.md

- **Staging**: db.m5.xlarge, 200GB, 7-day backups  ```

- **Production**: db.m5.2xlarge, 500GB, 14-day backups

## ⚙️ Configuration

## License

### Environment Variables

This project is licensed under the MIT License.
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

## 👥 Authors

- **Hossam Aladdin** - *Initial work* - [hossamaladdin](https://github.com/hossamaladdin)

## 🙏 Acknowledgments

- AWS Documentation Team
- Terraform Community
- HashiCorp