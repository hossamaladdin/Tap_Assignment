# Quick Start Guide

This guide will help you deploy the RDS SQL Server infrastructure in under 15 minutes.

## Prerequisites ✓

Before starting, ensure you have:
- ✅ Terraform >= 1.0 installed
- ✅ AWS CLI >= 2.0 configured
- ✅ AWS account with appropriate permissions
- ✅ Git (to clone the repository)

## 5-Minute Quick Deploy

### Step 1: Clone and Setup (1 minute)

```bash
# Clone the repository
git clone https://github.com/hossamaladdin/Tap_Assignment.git
cd Tap_Assignment

# Initialize Terraform
terraform init
```

### Step 2: Configure (2 minutes)

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration (minimal changes needed)
vim terraform.tfvars
```

**Minimum required changes:**
```hcl
aws_region   = "us-east-1"           # Your AWS region
environment  = "dev"                 # dev, staging, or prod
```

**Optional but recommended:**
```hcl
# Add your IP for database access (if needed)
allowed_cidr_blocks = ["YOUR_IP/32"]

# Enable bastion host for database access
enable_bastion = true
bastion_key_name = "your-ssh-key"
bastion_allowed_cidr_blocks = ["YOUR_IP/32"]
```

### Step 3: Plan Deployment (1 minute)

```bash
# Review what will be created
terraform plan
```

Expected resources to be created:
- 1 VPC with 6 subnets
- 1 RDS SQL Server instance (Multi-AZ)
- 1 Secrets Manager secret
- 2 Security groups
- 4 CloudWatch alarms
- Multiple IAM roles and policies
- 1 Bastion host (if enabled)

### Step 4: Deploy (10 minutes)

```bash
# Deploy infrastructure
terraform apply

# Type 'yes' when prompted
```

⏱️ **Deployment time:** ~10-15 minutes (RDS provisioning is the longest part)

### Step 5: Get Outputs (1 minute)

```bash
# View all outputs
terraform output

# Get specific outputs
terraform output rds_endpoint
terraform output db_secret_name
terraform output bastion_public_ip  # If bastion enabled
```

## Post-Deployment: Connect to Database

### Option A: Using Bastion Host (Recommended)

```bash
# SSH to bastion
ssh -i ~/.ssh/your-key.pem ec2-user@$(terraform output -raw bastion_public_ip)

# Once on bastion, connect to RDS
./connect_to_rds.sh $(terraform output -raw rds_endpoint | cut -d: -f1)
```

### Option B: Using SQL Server Management Studio (SSMS)

1. **Get RDS Endpoint:**
   ```bash
   terraform output rds_endpoint
   ```

2. **Get Password from Secrets Manager:**
   ```bash
   aws secretsmanager get-secret-value \
     --secret-id $(terraform output -raw db_secret_name) \
     --query SecretString --output text | jq -r '.password'
   ```

3. **Connect in SSMS:**
   - Server: `<rds-endpoint>`
   - Authentication: SQL Server Authentication
   - Login: `sqladmin`
   - Password: (from step 2)

### Option C: Using sqlcmd (if you have SQL Server tools)

```bash
# Get credentials and connect
sqlcmd -S $(terraform output -raw rds_endpoint | cut -d: -f1) \
       -U sqladmin \
       -P $(aws secretsmanager get-secret-value \
            --secret-id $(terraform output -raw db_secret_name) \
            --query SecretString --output text | jq -r '.password') \
       -C
```

## Verify Deployment

### Test Database Connection

```sql
-- Run these queries after connecting
SELECT @@VERSION;
GO

SELECT name, database_id, create_date FROM sys.databases;
GO

-- Check current connections
SELECT COUNT(*) as ActiveSessions 
FROM sys.dm_exec_sessions 
WHERE is_user_process = 1;
GO
```

### Verify High Availability

```bash
# Check Multi-AZ status
aws rds describe-db-instances \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --query 'DBInstances[0].MultiAZ' \
  --output text

# Expected: true (in staging/prod)
```

### Check Monitoring

```bash
# View CloudWatch metrics
aws cloudwatch list-metrics \
  --namespace AWS/RDS \
  --dimensions Name=DBInstanceIdentifier,Value=$(terraform output -raw rds_instance_id)

# Check if Performance Insights is enabled
aws rds describe-db-instances \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --query 'DBInstances[0].PerformanceInsightsEnabled' \
  --output text
```

## Environment-Specific Deployments

### Development Environment

```bash
terraform apply -var-file=environments/dev.tfvars
```

Features:
- Single-AZ (cost-optimized)
- db.t3.large instance
- 3-day backup retention
- No NAT Gateway (optional)

### Staging Environment

```bash
terraform apply -var-file=environments/staging.tfvars
```

Features:
- Multi-AZ for HA
- db.m5.xlarge instance
- 7-day backup retention
- Bastion host enabled

### Production Environment

```bash
terraform apply -var-file=environments/prod.tfvars
```

Features:
- Multi-AZ for HA
- db.m5.2xlarge instance
- 14-day backup retention
- Enhanced monitoring
- Deletion protection enabled

## Common Tasks

### Update Database Password

```bash
# Using the provided script
./scripts/update_secret.sh $(terraform output -raw db_secret_name) <new-password>

# Then update RDS
aws rds modify-db-instance \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --master-user-password <new-password> \
  --apply-immediately
```

### Scale Instance Size

```bash
# Edit terraform.tfvars
# Change: rds_instance_class = "db.m5.xlarge"

# Apply changes
terraform apply
```

### Create Manual Backup

```bash
aws rds create-db-snapshot \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --db-snapshot-identifier manual-backup-$(date +%Y%m%d)
```

### View Logs

```bash
# Error logs
aws logs tail /aws/rds/instance/$(terraform output -raw rds_instance_id)/error --follow

# Agent logs
aws logs tail /aws/rds/instance/$(terraform output -raw rds_instance_id)/agent --follow
```

## Cleanup

### Destroy Infrastructure

⚠️ **Warning:** This will permanently delete all resources!

```bash
# For dev environment (deletion protection disabled)
terraform destroy -var-file=environments/dev.tfvars

# For prod environment (requires disabling deletion protection first)
# 1. Edit terraform.tfvars: rds_deletion_protection = false
# 2. Apply changes: terraform apply
# 3. Then destroy: terraform destroy
```

### Remove Specific Resources

```bash
# Remove only bastion host
terraform destroy -target=module.bastion

# Remove and recreate RDS (with downtime)
terraform taint module.rds.aws_db_instance.sqlserver
terraform apply
```

## Troubleshooting Quick Fixes

### Issue: Terraform Init Fails

```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Issue: AWS Credentials Not Found

```bash
aws configure
# Or
export AWS_PROFILE=your-profile
```

### Issue: RDS Creation Fails

Check:
1. AWS service quotas: `aws service-quotas get-service-quota --service-code rds --quota-code L-7B6409FD`
2. Subnet configuration: Ensure subnets span multiple AZs
3. Security groups: Verify no conflicting rules

### Issue: Cannot Connect to RDS

```bash
# Test network connectivity from bastion
nc -zv $(terraform output -raw rds_endpoint | cut -d: -f1) 1433

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw rds_security_group_id)

# Verify credentials
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw db_secret_name)
```

## Next Steps

1. **Read the full README:** `cat README.md`
2. **Review architecture:** `cat docs/ARCHITECTURE.md`
3. **Learn operations:** `cat docs/OPERATIONS.md`
4. **Customize configuration:** Edit `terraform.tfvars` and modules
5. **Set up monitoring:** Configure CloudWatch alarms and SNS notifications
6. **Implement backups:** Set up automated backup schedules
7. **Plan DR strategy:** Consider cross-region replication

## Support

For issues or questions:
1. Check [Troubleshooting](../README.md#troubleshooting) section
2. Review [Operations Guide](OPERATIONS.md)
3. Consult [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
4. Open an issue on GitHub

## Cost Estimation

### Development Environment
- **Monthly cost:** ~$300-400
- RDS t3.large (Single-AZ): ~$250
- Storage (100GB gp3): ~$10
- Backups: ~$5
- Data transfer: ~$20

### Staging Environment
- **Monthly cost:** ~$1,200-1,500
- RDS m5.xlarge (Multi-AZ): ~$1,100
- Storage (200GB gp3): ~$20
- Backups: ~$15
- NAT Gateway: ~$45
- Data transfer: ~$30

### Production Environment
- **Monthly cost:** ~$2,500-3,000
- RDS m5.2xlarge (Multi-AZ): ~$2,200
- Storage (500GB gp3): ~$50
- Backups: ~$30
- NAT Gateway: ~$45
- Enhanced monitoring: ~$15
- Data transfer: ~$50

**Cost-saving tips:**
- Use Reserved Instances (up to 60% savings)
- Stop dev instances when not in use
- Optimize storage with autoscaling
- Use appropriate instance sizes

## Success Criteria

Your deployment is successful if:
- ✅ RDS instance status is "available"
- ✅ Can connect to database using credentials from Secrets Manager
- ✅ Can query system databases
- ✅ CloudWatch alarms are created and active
- ✅ Performance Insights is enabled (if configured)
- ✅ Automated backups are running
- ✅ Multi-AZ is active (in staging/prod)

---

**Congratulations!** 🎉 You've successfully deployed a production-ready RDS SQL Server infrastructure on AWS!
