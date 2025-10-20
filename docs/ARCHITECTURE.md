# Architecture Overview

## High-Level Architecture

This infrastructure deploys a highly available RDS SQL Server instance on AWS with the following architecture:

### Components

#### 1. Network Layer (VPC Module)
- **VPC**: Isolated virtual network (10.0.0.0/16)
- **Public Subnets**: 3 subnets across 3 AZs for internet-facing resources
- **Private Subnets**: 3 subnets across 3 AZs for RDS instances
- **Internet Gateway**: Enables internet access for public subnets
- **NAT Gateways**: Enables outbound internet for private subnets (optional)
- **Route Tables**: Separate routing for public and private subnets
- **VPC Flow Logs**: Network traffic logging for security analysis

#### 2. Database Layer (RDS Module)
- **RDS SQL Server**: Managed database service
  - Engine: SQL Server Standard Edition 2019
  - Multi-AZ deployment for high availability
  - Encrypted storage (AWS KMS)
  - Automated backups with configurable retention
  - Performance Insights for query analysis
  - Enhanced monitoring (60-second granularity)
  
- **DB Subnet Group**: Spans multiple AZs for high availability
- **Parameter Group**: Custom SQL Server parameters for optimization
- **Option Group**: Additional SQL Server features and configurations
- **Security Group**: Controls inbound/outbound traffic

#### 3. Security Layer
- **Secrets Manager**: Stores database credentials securely
  - Auto-generated passwords (32 characters)
  - Encrypted at rest
  - Automatic rotation support (can be enabled)
  
- **IAM Roles**:
  - RDS monitoring role for CloudWatch
  - EC2 role for Secrets Manager access
  
- **Security Groups**:
  - RDS SG: Port 1433 from authorized sources only
  - Bastion SG: Port 22 from authorized IPs
  - No public access to RDS

#### 4. Monitoring Layer
- **CloudWatch Alarms**:
  - CPU utilization > 80%
  - Free memory < 1GB
  - Free storage < 10GB
  - Database connections > 100
  
- **CloudWatch Logs**:
  - SQL Server error logs
  - SQL Server agent logs
  
- **Performance Insights**:
  - Query performance analysis
  - Wait event analysis
  - Retention: 7 days (dev/staging), 31 days (prod)

#### 5. Access Layer (Bastion Module - Optional)
- **EC2 Bastion Host**:
  - Amazon Linux 2023
  - SQL Server command-line tools pre-installed
  - IAM role for Secrets Manager access
  - Session Manager enabled (no SSH keys required)
  - Connection scripts included

## Data Flow

### 1. Application to Database
```
Application/User → VPN/DirectConnect → VPC Private Subnet → RDS Security Group → RDS SQL Server
```

### 2. Bastion to Database
```
User → SSH/SSM → Bastion Host (Public Subnet) → RDS Security Group → RDS SQL Server
```

### 3. Credential Retrieval
```
Application/Bastion → IAM Role → Secrets Manager → Database Credentials
```

### 4. Monitoring Data
```
RDS Instance → CloudWatch Metrics/Logs → CloudWatch Alarms → SNS (optional)
```

## High Availability Design

### Multi-AZ Deployment
- **Primary Instance**: Active in AZ-1a
- **Standby Instance**: Passive in AZ-1b
- **Synchronous Replication**: Data replicated in real-time
- **Automatic Failover**: Typically 60-120 seconds
- **DNS Endpoint**: Automatically points to active instance

### Failure Scenarios

#### 1. Instance Failure
- Automatic failover to standby in different AZ
- DNS endpoint updated automatically
- Minimal downtime (1-2 minutes)

#### 2. AZ Failure
- Standby promoted to primary
- New standby created in healthy AZ
- Applications reconnect automatically

#### 3. Region Failure
- Requires manual intervention
- Use cross-region read replicas (can be added)
- Promote read replica to primary

## Backup and Recovery

### Automated Backups
- **Frequency**: Daily during backup window
- **Retention**: 
  - Dev: 3 days
  - Staging: 7 days
  - Production: 14 days
- **Storage**: S3 (encrypted)
- **Point-in-Time Recovery**: Within retention period

### Manual Snapshots
- Can be created anytime
- Retained until manually deleted
- Can be copied across regions
- Can be shared with other accounts

### Recovery Procedures

#### Point-in-Time Recovery
```bash
# Restore to specific time
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier mydb \
  --target-db-instance-identifier mydb-restored \
  --restore-time 2025-10-20T10:00:00Z
```

#### Snapshot Restore
```bash
# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier mydb-restored \
  --db-snapshot-identifier mydb-snapshot-2025-10-20
```

## Scalability

### Vertical Scaling
- **Instance Size**: Change instance class
- **Storage**: Auto-scaling enabled
- **Downtime**: Required for instance class change (Multi-AZ: minimal)

### Storage Autoscaling
- Automatically increases storage when threshold reached
- Maximum storage configured per environment
- No downtime required

### Read Replicas (Can be added)
- Up to 5 read replicas per primary
- Can be in same or different region
- Asynchronous replication
- Offload read traffic from primary

## Security Architecture

### Network Security
```
Internet → IGW → Public Subnet (Bastion) → Private Subnet (RDS)
                                ↓
                          NAT Gateway → Internet (for updates)
```

### Defense in Depth
1. **Network Layer**: VPC, subnets, NACLs
2. **Perimeter Layer**: Security groups, bastion host
3. **Application Layer**: IAM roles, least privilege
4. **Data Layer**: Encryption at rest, encryption in transit
5. **Monitoring Layer**: CloudWatch, VPC Flow Logs

### Encryption

#### At Rest
- **RDS Storage**: AWS KMS encryption
- **Backups**: Encrypted with same key
- **Snapshots**: Encrypted automatically

#### In Transit
- **TLS/SSL**: Enforced for all connections
- **Certificate**: RDS-provided certificate
- **Verification**: Optional certificate validation

## Cost Optimization

### Resource Optimization
- **Right-sizing**: Different instance sizes per environment
- **Storage**: gp3 for better cost/performance
- **Autoscaling**: Prevents over-provisioning
- **Backups**: Retention based on requirements

### Environment Differences
| Resource | Dev | Staging | Production |
|----------|-----|---------|------------|
| Multi-AZ | No | Yes | Yes |
| Instance | t3.large | m5.xlarge | m5.2xlarge |
| Storage | 100GB | 200GB | 500GB |
| Backup Retention | 3 days | 7 days | 14 days |
| NAT Gateway | No | Yes | Yes |

### Cost Allocation
- **Tagging**: Environment, Project, Owner, CostCenter
- **Cost Explorer**: Track spending by tag
- **Budgets**: Set alerts for overspending

## Disaster Recovery

### RPO (Recovery Point Objective)
- **Automated Backups**: Up to 5 minutes
- **Multi-AZ**: Real-time (synchronous replication)
- **Cross-Region Replicas**: Seconds to minutes

### RTO (Recovery Time Objective)
- **Multi-AZ Failover**: 1-2 minutes
- **Point-in-Time Restore**: 30-60 minutes
- **Cross-Region Promotion**: 5-15 minutes

### DR Strategies

#### Strategy 1: Multi-AZ (Implemented)
- **RPO**: ~5 minutes
- **RTO**: 1-2 minutes
- **Cost**: Medium (2x compute)
- **Use**: Production

#### Strategy 2: Backup and Restore
- **RPO**: Up to 24 hours
- **RTO**: 1-4 hours
- **Cost**: Low (storage only)
- **Use**: Development

#### Strategy 3: Cross-Region Replication (Can be added)
- **RPO**: Seconds
- **RTO**: 5-15 minutes
- **Cost**: High (2x everything)
- **Use**: Mission-critical

## Compliance Considerations

### Security Standards
- ✅ Encryption at rest and in transit
- ✅ Network isolation
- ✅ Access logging and monitoring
- ✅ Automated backups
- ✅ Multi-AZ for availability

### Audit Requirements
- ✅ CloudWatch Logs for database activity
- ✅ VPC Flow Logs for network traffic
- ✅ CloudTrail for API calls
- ✅ Secrets Manager audit logs

### Data Retention
- Configurable backup retention
- Manual snapshots for long-term retention
- CloudWatch Logs retention policies

## Future Enhancements

### Planned Features
1. **Read Replicas**: For read scaling
2. **Cross-Region Replication**: For disaster recovery
3. **Automated Secret Rotation**: For enhanced security
4. **SQL Server Audit**: For compliance
5. **Database Migration Service**: For data migration
6. **AWS Backup**: For centralized backup management

### Monitoring Improvements
1. **SNS Notifications**: For CloudWatch alarms
2. **Custom Metrics**: Application-specific monitoring
3. **Log Analysis**: Automated log parsing and alerting
4. **Performance Tuning**: Automated query optimization

### Security Enhancements
1. **AWS WAF**: If exposing through API Gateway
2. **GuardDuty**: Threat detection
3. **Security Hub**: Centralized security findings
4. **Macie**: Data classification and protection
