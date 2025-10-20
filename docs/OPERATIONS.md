# Operations Guide

## Table of Contents
- [Daily Operations](#daily-operations)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [Backup and Recovery](#backup-and-recovery)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [Scaling](#scaling)
- [Security Operations](#security-operations)

## Daily Operations

### Health Checks

#### Check RDS Instance Status
```bash
# Get instance status
aws rds describe-db-instances \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --query 'DBInstances[0].DBInstanceStatus' \
  --output text

# Expected output: available
```

#### Check CloudWatch Metrics
```bash
# CPU utilization (last hour)
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=$(terraform output -raw rds_instance_id) \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# Free storage space
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name FreeStorageSpace \
  --dimensions Name=DBInstanceIdentifier,Value=$(terraform output -raw rds_instance_id) \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

#### Check Active Connections
```bash
# From bastion or SQL client
sqlcmd -S $(terraform output -raw rds_endpoint | cut -d: -f1) -U sqladmin -P <password> -Q "SELECT COUNT(*) as ActiveConnections FROM sys.dm_exec_sessions WHERE is_user_process = 1"
```

### Log Monitoring

#### View Error Logs
```bash
# List available logs
aws rds describe-db-log-files \
  --db-instance-identifier $(terraform output -raw rds_instance_id)

# Download latest error log
aws rds download-db-log-file-portion \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --log-file-name error/errorlog \
  --output text

# Tail CloudWatch logs
aws logs tail /aws/rds/instance/$(terraform output -raw rds_instance_id)/error --follow
```

## Deployment

### Initial Deployment

#### 1. Prerequisites Check
```bash
# Run setup script
./scripts/setup.sh

# Or manually check:
terraform version  # >= 1.0
aws --version      # >= 2.0
aws sts get-caller-identity  # Verify credentials
```

#### 2. Initialize Terraform
```bash
terraform init
```

#### 3. Review Configuration
```bash
# Copy and edit tfvars
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# Or use environment-specific config
vim environments/prod.tfvars
```

#### 4. Plan Deployment
```bash
# Review what will be created
terraform plan -var-file=environments/prod.tfvars -out=plan.out

# Review plan details
terraform show plan.out
```

#### 5. Deploy
```bash
# Apply the plan
terraform apply plan.out

# Or apply directly (with confirmation)
terraform apply -var-file=environments/prod.tfvars
```

#### 6. Post-Deployment
```bash
# Get outputs
terraform output

# Save important information
terraform output -json > outputs.json

# Update secret with RDS endpoint (if needed)
./scripts/update_secret.sh \
  $(terraform output -raw db_secret_name) \
  $(terraform output -raw rds_endpoint | cut -d: -f1)
```

### Updates and Changes

#### Update Infrastructure
```bash
# 1. Make changes to .tf or .tfvars files

# 2. Plan changes
terraform plan -var-file=environments/prod.tfvars

# 3. Review changes carefully
# Look for any resources being destroyed/recreated

# 4. Apply changes
terraform apply -var-file=environments/prod.tfvars
```

#### Update RDS Instance Class
```bash
# In terraform.tfvars or environments/prod.tfvars
# Change: rds_instance_class = "db.m5.2xlarge"

terraform apply -var-file=environments/prod.tfvars

# Note: This will cause downtime if not Multi-AZ
# Multi-AZ: Standby upgraded first, then failover
```

#### Update SQL Server Parameters
```bash
# Edit modules/rds/main.tf parameter group
# Add or modify parameters

terraform apply -var-file=environments/prod.tfvars

# Note: Some parameters require reboot
# Check AWS documentation for specific parameters
```

### Rollback Procedures

#### Rollback Using Git
```bash
# Revert to previous version
git log --oneline  # Find commit hash
git checkout <commit-hash>

# Apply previous configuration
terraform apply -var-file=environments/prod.tfvars
```

#### Restore from Backup
See [Backup and Recovery](#backup-and-recovery) section.

## Monitoring

### CloudWatch Dashboards

#### Create Custom Dashboard
```bash
# Create dashboard JSON
cat > dashboard.json << 'EOF'
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/RDS", "CPUUtilization", {"stat": "Average"}],
          [".", "DatabaseConnections", {"stat": "Average"}],
          [".", "FreeableMemory", {"stat": "Average"}]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "RDS Metrics"
      }
    }
  ]
}
EOF

# Create dashboard
aws cloudwatch put-dashboard \
  --dashboard-name RDS-SQL-Server \
  --dashboard-body file://dashboard.json
```

### Performance Insights

#### Access Performance Insights
```bash
# Via AWS Console
# RDS → Databases → Your Instance → Performance Insights

# Or via API
aws pi describe-dimension-keys \
  --service-type RDS \
  --identifier $(terraform output -raw rds_instance_arn) \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --metric db.load.avg \
  --group-by '{"Group":"db.sql"}'
```

### Alerting

#### Configure SNS for Alarms
```bash
# Create SNS topic
aws sns create-topic --name rds-alarms

# Subscribe email
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:123456789012:rds-alarms \
  --protocol email \
  --notification-endpoint your-email@example.com

# Update CloudWatch alarms to use SNS
aws cloudwatch put-metric-alarm \
  --alarm-name rds-high-cpu \
  --alarm-actions arn:aws:sns:us-east-1:123456789012:rds-alarms \
  --metric-name CPUUtilization \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=DBInstanceIdentifier,Value=$(terraform output -raw rds_instance_id)
```

## Backup and Recovery

### Manual Snapshots

#### Create Snapshot
```bash
# Create manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --db-snapshot-identifier manual-snapshot-$(date +%Y%m%d-%H%M%S)

# Monitor snapshot progress
aws rds describe-db-snapshots \
  --db-snapshot-identifier manual-snapshot-$(date +%Y%m%d-%H%M%S) \
  --query 'DBSnapshots[0].[Status,PercentProgress]' \
  --output text
```

#### List Snapshots
```bash
# List all snapshots
aws rds describe-db-snapshots \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --query 'DBSnapshots[].[DBSnapshotIdentifier,SnapshotCreateTime,Status]' \
  --output table
```

#### Delete Old Snapshots
```bash
# Delete snapshot
aws rds delete-db-snapshot \
  --db-snapshot-identifier <snapshot-id>
```

### Restore Procedures

#### Point-in-Time Restore
```bash
# Restore to 2 hours ago
RESTORE_TIME=$(date -u -d '2 hours ago' +%Y-%m-%dT%H:%M:%S)

aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier $(terraform output -raw rds_instance_id) \
  --target-db-instance-identifier restored-instance \
  --restore-time $RESTORE_TIME \
  --db-subnet-group-name $(terraform output -raw db_subnet_group_name) \
  --vpc-security-group-ids $(terraform output -raw rds_security_group_id)
```

#### Snapshot Restore
```bash
# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier restored-instance \
  --db-snapshot-identifier <snapshot-id> \
  --db-subnet-group-name $(terraform output -raw db_subnet_group_name) \
  --vpc-security-group-ids $(terraform output -raw rds_security_group_id)
```

#### Verify Restored Database
```bash
# Wait for instance to be available
aws rds wait db-instance-available \
  --db-instance-identifier restored-instance

# Get endpoint
aws rds describe-db-instances \
  --db-instance-identifier restored-instance \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text

# Connect and verify data
sqlcmd -S <restored-endpoint> -U sqladmin -P <password>
```

## Maintenance

### Maintenance Windows

#### View Current Maintenance Window
```bash
aws rds describe-db-instances \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --query 'DBInstances[0].PreferredMaintenanceWindow' \
  --output text
```

#### Update Maintenance Window
```bash
# In terraform.tfvars or environments/prod.tfvars
# Change: rds_maintenance_window = "mon:04:00-mon:05:00"

terraform apply -var-file=environments/prod.tfvars
```

#### Apply Pending Maintenance
```bash
# Check for pending maintenance
aws rds describe-pending-maintenance-actions \
  --resource-identifier $(terraform output -raw rds_instance_arn)

# Apply immediately (during low traffic)
aws rds apply-pending-maintenance-action \
  --resource-identifier $(terraform output -raw rds_instance_arn) \
  --apply-action system-update \
  --opt-in-type immediate
```

### SQL Server Maintenance

#### Update Statistics
```sql
-- Connect to database
USE YourDatabase;
GO

-- Update statistics on all tables
EXEC sp_updatestats;
GO

-- Update statistics with full scan (more accurate, takes longer)
EXEC sp_MSforeachtable 'UPDATE STATISTICS ? WITH FULLSCAN';
GO
```

#### Rebuild Indexes
```sql
-- Rebuild all indexes in database
USE YourDatabase;
GO

DECLARE @TableName NVARCHAR(255);
DECLARE @SQL NVARCHAR(MAX);

DECLARE TableCursor CURSOR FOR
SELECT name FROM sys.tables WHERE is_ms_shipped = 0;

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER INDEX ALL ON [' + @TableName + '] REBUILD WITH (ONLINE = OFF);';
    EXEC sp_executesql @SQL;
    FETCH NEXT FROM TableCursor INTO @TableName;
END

CLOSE TableCursor;
DEALLOCATE TableCursor;
GO
```

#### Check Database Integrity
```sql
-- Check database integrity
DBCC CHECKDB('YourDatabase') WITH NO_INFOMSGS;
GO
```

## Scaling

### Vertical Scaling (Instance Size)

#### Scale Up
```bash
# Update instance class
# In environments/prod.tfvars:
# rds_instance_class = "db.m5.4xlarge"

terraform plan -var-file=environments/prod.tfvars
terraform apply -var-file=environments/prod.tfvars

# Monitor scaling progress
aws rds describe-db-instances \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --query 'DBInstances[0].DBInstanceStatus' \
  --output text
```

#### Scale Down (Cost Optimization)
```bash
# Same process, but smaller instance
# rds_instance_class = "db.t3.large"

terraform apply -var-file=environments/prod.tfvars
```

### Storage Scaling

#### Increase Storage
```bash
# Update allocated storage
# In environments/prod.tfvars:
# rds_allocated_storage = 200

terraform apply -var-file=environments/prod.tfvars

# Note: Storage can only be increased, never decreased
# Autoscaling is already enabled up to max_allocated_storage
```

### Read Replicas (Future Enhancement)

#### Create Read Replica
```bash
# Add to Terraform configuration
resource "aws_db_instance" "read_replica" {
  identifier             = "${var.name_prefix}-sqlserver-replica"
  replicate_source_db    = aws_db_instance.sqlserver.id
  instance_class         = var.rds_instance_class
  publicly_accessible    = false
  skip_final_snapshot    = true
  
  tags = var.tags
}
```

## Security Operations

### Credential Rotation

#### Rotate Master Password
```bash
# Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)

# Update in Secrets Manager
aws secretsmanager update-secret \
  --secret-id $(terraform output -raw db_secret_name) \
  --secret-string "{\"username\":\"sqladmin\",\"password\":\"$NEW_PASSWORD\",\"host\":\"$(terraform output -raw rds_endpoint | cut -d: -f1)\",\"port\":1433,\"engine\":\"sqlserver\"}"

# Update RDS master password
aws rds modify-db-instance \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --master-user-password "$NEW_PASSWORD" \
  --apply-immediately
```

### Security Group Updates

#### Add IP to Allowed List
```bash
# In terraform.tfvars:
# allowed_cidr_blocks = ["203.0.113.0/24", "198.51.100.0/24"]

terraform apply -var-file=environments/prod.tfvars
```

#### Review Security Group Rules
```bash
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw rds_security_group_id) \
  --query 'SecurityGroups[0].IpPermissions' \
  --output json
```

### Audit Logging

#### Enable SQL Server Audit (Future)
```hcl
# In modules/rds/main.tf option group
option {
  option_name = "SQLSERVER_AUDIT"
  option_settings {
    name  = "IAM_ROLE_ARN"
    value = aws_iam_role.audit.arn
  }
  option_settings {
    name  = "S3_BUCKET_ARN"
    value = aws_s3_bucket.audit.arn
  }
}
```

### Compliance Reporting

#### Generate Compliance Report
```bash
# Export RDS configuration
aws rds describe-db-instances \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --query 'DBInstances[0]' \
  --output json > rds-config.json

# Check encryption
jq '.StorageEncrypted' rds-config.json

# Check Multi-AZ
jq '.MultiAZ' rds-config.json

# Check backup retention
jq '.BackupRetentionPeriod' rds-config.json
```

## Troubleshooting

See [Troubleshooting Guide](../README.md#troubleshooting) in main README.

## Additional Resources

- [AWS RDS User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/)
- [SQL Server Best Practices](https://docs.microsoft.com/en-us/sql/sql-server/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
