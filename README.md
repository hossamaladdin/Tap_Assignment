
# Tap Assignment: Unified Terraform AWS RDS SQL Server

Provision SQL Server RDS on AWS with a unified, minimal Terraform setup supporting multiple environments (dev, stg, prod, and more).

## Prerequisites (GitHub Codespaces)

- AWS CLI configured (`aws configure`)
- Terraform >= 1.3 installed
- jq (for parsing secrets)
- S3 bucket for remote state (see below)

## Folder Structure

```
├── README.md
├── prep_s3_state.sh
├── env/
│   ├── dev/main.tf
│   ├── stg/main.tf
│   ├── prod/main.tf
│   └── <new-env>/main.tf
└── modules/
    ├── deployment/
    ├── vpc/
    ├── rds/
    ├── iam/
    ├── secrets/
    └── monitoring/
```

## How It Works

- Each environment (dev, stg, prod, etc.) has its own folder and `main.tf`.
- All config is in `main.tf` per env; no tfvars, no workspace switching, no duplicate state.
- Remote state is stored in S3, with a unique key per environment (e.g. `dev/terraform.tfstate`).

## Deploying an Environment

```bash
# Example for dev
cd env/dev
terraform init
terraform plan
terraform apply

# Example for prod
cd env/prod
terraform init
terraform plan
terraform apply
```

## Adding a New Environment (e.g. preprod)

Run the following bash script to create a new environment folder and main.tf:

```bash
./prep_new_env.sh preprod
```

This will:
- Create `env/preprod/main.tf` (copy from dev)
- Update backend S3 key and tags for the new environment

### prep_new_env.sh
```bash
#!/bin/bash
set -e
NEW_ENV="$1"
if [ -z "$NEW_ENV" ]; then echo "Usage: $0 <env-name>"; exit 1; fi
cp -r env/dev env/$NEW_ENV
sed -i "s/environment = \"dev\"/environment = \"$NEW_ENV\"/g" env/$NEW_ENV/main.tf
sed -i "s/key    = \"dev\/terraform.tfstate\"/key    = \"$NEW_ENV\/terraform.tfstate\"/g" env/$NEW_ENV/main.tf
sed -i "s/Environment = \"dev\"/Environment = \"$NEW_ENV\"/g" env/$NEW_ENV/main.tf
echo "Created env/$NEW_ENV/main.tf for environment $NEW_ENV."
```

## S3 State Handling

- S3 does **not** require you to manually create folders for each environment; Terraform will create the state file at the specified key automatically.
- The provided `prep_s3_state.sh` script creates the S3 bucket and (optionally) empty folders, but this is not strictly required.
- Each environment's backend block uses a unique S3 key, so state files never overlap.

## Outputs & Connection Info

After deployment, use these commands:

```bash
terraform output rds_endpoint
terraform output secret_arn
aws secretsmanager get-secret-value --secret-id $(terraform output -raw secret_arn) --query SecretString --output text | jq -r '.password'
```

## Production Checklist

- Set `single_nat_gateway = false` for high availability
- Restrict `allowed_cidr_blocks` to specific IP ranges
- Configure `alarm_actions` with SNS topic for notifications
- Enable `enable_rotation = true` for password rotation
- Review and adjust alarm thresholds for your workload

## License

MIT License - See LICENSE file for details.

## Architecture

### Infrastructure Components

- **VPC**: 10.0.0.0/16 with 3 public and 3 private subnets across 3 AZs
- **RDS**: SQL Server Standard Edition (Multi-AZ, encrypted, enhanced monitoring)
- **NAT Gateway**: Configurable (single or multi-AZ)
- **Secrets Manager**: Auto-generated passwords with optional rotation
- **CloudWatch**: Dashboards and alarms for CPU, memory, storage, connections, and latency
- **IAM**: Minimal privilege roles for RDS monitoring and secrets access

### Cost Optimization

By default, this configuration uses a **single NAT Gateway** to reduce costs:
- **Single NAT**: ~$32/month (enabled by default)
- **Multi-AZ NAT**: ~$97/month (3 gateways)

To enable multi-AZ NAT for production high availability:
```hcl
# In your tfvars or variables
single_nat_gateway = false
```

**Note**: RDS Multi-AZ provides database redundancy regardless of NAT Gateway configuration.

## Environment Management

### Workspace-based Deployment

Each environment uses its own Terraform workspace and state file:

```bash
# Development
terraform workspace select dev
terraform apply -var="environment=dev"

# Staging
terraform workspace select staging
terraform apply -var="environment=staging"

# Production
terraform workspace select production
terraform apply -var="environment=production"
```

### Backend Configuration

Configure your `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket               = "terraform-state-hossam-2025"
    workspace_key_prefix = "sql-rds"
    region               = "us-east-1"
  }
}
```

State files are stored as: `sql-rds/<workspace>/terraform.tfstate`

### Concurrent Operations

**IMPORTANT**: This configuration **allows concurrent Terraform operations** by not using DynamoDB state locking. This is intentional for simplified operations in single-user scenarios.

If you're working in a team environment and need to prevent concurrent modifications, you can add DynamoDB locking manually (not included by default).

## Configuration Options

### Key Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `environment` | (required) | Environment name: dev, staging, or production |
| `single_nat_gateway` | `true` | Use single NAT for cost savings |
| `deletion_protection` | `true` | Protect RDS from accidental deletion |
| `allowed_cidr_blocks` | `["0.0.0.0/0"]` | CIDR blocks allowed to access RDS |
| `enable_rotation` | `false` | Enable automatic password rotation |
| `alarm_actions` | `[]` | SNS topic ARNs for alarm notifications |

### Security Configuration

#### Network Access

**Default Configuration**: `allowed_cidr_blocks = ["0.0.0.0/0"]`

This allows access from any IP address and is **intentionally configured for connection testing purposes**. For production deployments, you should restrict this to specific IP ranges:

```hcl
# Example: Restrict to specific office/VPN IP
allowed_cidr_blocks = ["203.0.113.0/24", "198.51.100.0/24"]
```

To test connectivity before restricting access:
1. Deploy with default open access
2. Verify you can connect from your client
3. Update `allowed_cidr_blocks` to your specific IPs
4. Re-apply Terraform

#### Password Rotation

Enable automatic password rotation with a Lambda function:

```hcl
# In deployment module or root
enable_rotation     = true
rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:SecretsManagerRotation"
rotation_days       = 30
```

You'll need to create the rotation Lambda function separately using AWS-provided templates.

## Monitoring and Alerts

### CloudWatch Dashboard

A comprehensive dashboard is automatically created showing:
- CPU Utilization (Average and Maximum)
- Database Connections
- Freeable Memory
- Free Storage Space
- Read/Write Latency
- Read/Write IOPS

Access it via:
```bash
# Get dashboard name
terraform output cloudwatch_dashboard_name

# Open in AWS Console
aws cloudwatch get-dashboard --dashboard-name $(terraform output -raw cloudwatch_dashboard_name)
```

### CloudWatch Alarms

Six alarms are configured by default:
1. **CPU High**: Triggers when CPU > 80%
2. **Memory Low**: Triggers when free memory < 1GB
3. **Storage Low**: Triggers when free storage < 10GB
4. **Connections High**: Triggers when connections > 100
5. **Read Latency High**: Triggers when latency > 0.1s
6. **Write Latency High**: Triggers when latency > 0.1s

#### Configure Alarm Notifications

To receive notifications, create an SNS topic and add its ARN:

```bash
# Create SNS topic
aws sns create-topic --name rds-alerts

# Subscribe your email
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:123456789012:rds-alerts \
  --protocol email \
  --notification-endpoint your-email@example.com

# Add to Terraform
alarm_actions = ["arn:aws:sns:us-east-1:123456789012:rds-alerts"]
```

## Testing and Connecting

### 1. Verify Deployment

```bash
# Check RDS instance status
aws rds describe-db-instances \
  --db-instance-identifier $(terraform output -raw rds_instance_id) \
  --query 'DBInstances[0].DBInstanceStatus'

# Should return: "available"
```

### 2. Get Connection Credentials

```bash
# Get endpoint
ENDPOINT=$(terraform output -raw rds_endpoint)

# Get password from Secrets Manager
SECRET_ARN=$(terraform output -raw secret_arn)
PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_ARN \
  --query SecretString \
  --output text | jq -r '.password')

# Get username (default: sqladmin)
USERNAME=$(terraform output -raw db_username)
```

### 3. Test Connection

#### Using sqlcmd (Microsoft SQL Server CLI)

```bash
# Install sqlcmd if needed:
# macOS: brew install sqlcmd
# Linux: https://learn.microsoft.com/en-us/sql/tools/sqlcmd-utility

# Connect to database
sqlcmd -S $ENDPOINT -U $USERNAME -P $PASSWORD -Q "SELECT @@VERSION"
```

#### Using Azure Data Studio / SQL Server Management Studio (SSMS)

1. Open Azure Data Studio or SSMS
2. Create new connection:
   - **Server**: `<rds_endpoint>` (from terraform output)
   - **Authentication**: SQL Server Authentication
   - **Username**: `sqladmin` (or your configured username)
   - **Password**: `<from Secrets Manager>`
   - **Port**: 1433
   - **Encrypt connection**: Yes

3. Click Connect

#### Using Python (pymssql)

```python
import pymssql
import json
import boto3

# Get credentials from Secrets Manager
client = boto3.client('secretsmanager')
secret = client.get_secret_value(SecretId='<secret_arn>')
creds = json.loads(secret['SecretString'])

# Connect to RDS
conn = pymssql.connect(
    server=creds['host'],
    user=creds['username'],
    password=creds['password'],
    port=creds['port'],
    database='master'
)

cursor = conn.cursor()
cursor.execute('SELECT @@VERSION')
print(cursor.fetchone())
conn.close()
```

### 4. Troubleshooting Connection Issues

#### Check Security Group Rules

```bash
# Get security group ID
SG_ID=$(terraform output -raw rds_security_group_id)

# View ingress rules
aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --query 'SecurityGroups[0].IpPermissions'
```

Verify port 1433 is open to your IP address.

#### Check VPC Flow Logs

```bash
# View flow logs for connection attempts
aws logs tail /aws/vpc/sql-rds-dev --follow
```

Look for REJECT entries that might indicate blocked traffic.

#### Test from Bastion Host (if deployed)

If direct connection fails, consider deploying a bastion host (see section below).

## Bastion Host (Optional)

A bastion host provides secure access to RDS from the public internet. This module doesn't include a bastion by default, but you can add one easily.

### Option 1: EC2 Bastion Host

Create a simple bastion in a public subnet:

```hcl
# Add to your configuration
resource "aws_instance" "bastion" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 (update for your region)
  instance_type = "t3.micro"
  subnet_id     = module.deployment.public_subnet_ids[0]

  vpc_security_group_ids = [aws_security_group.bastion.id]

  iam_instance_profile = module.deployment.ec2_secrets_instance_profile_name

  user_data = <<-EOF
              #!/bin/bash
              yum install -y https://packages.microsoft.com/rhel/8/prod/mssql-tools-18.1.1.1-1.x86_64.rpm
              EOF

  tags = {
    Name = "sql-rds-bastion"
  }
}

resource "aws_security_group" "bastion" {
  name        = "sql-rds-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = module.deployment.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"] # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow bastion to connect to RDS
resource "aws_security_group_rule" "rds_from_bastion" {
  type                     = "ingress"
  from_port                = 1433
  to_port                  = 1433
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = module.deployment.rds_security_group_id
}
```

### Connecting via Bastion

```bash
# SSH to bastion
ssh -i your-key.pem ec2-user@<bastion-public-ip>

# On bastion, get credentials from Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id <secret-arn> \
  --query SecretString \
  --output text | jq -r '.password'

# Connect to RDS
sqlcmd -S <rds-endpoint> -U sqladmin -P <password> -Q "SELECT @@VERSION"
```

### Option 2: AWS Systems Manager Session Manager (Recommended)

No SSH keys needed, uses IAM authentication:

```hcl
# Add to bastion instance
resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
```

Connect:
```bash
# Connect via Session Manager
aws ssm start-session --target <bastion-instance-id>

# Then connect to RDS as shown above
```

### Option 3: SSH Tunnel (Port Forwarding)

For direct local access through bastion:

```bash
# Create SSH tunnel
ssh -i your-key.pem -L 1433:<rds-endpoint>:1433 ec2-user@<bastion-public-ip> -N

# In another terminal, connect to localhost
sqlcmd -S localhost,1433 -U sqladmin -P <password>
```

## Outputs

Key outputs available after deployment:

```bash
terraform output rds_endpoint              # RDS connection endpoint
terraform output rds_instance_id           # RDS instance identifier
terraform output secret_arn                # Secrets Manager ARN
terraform output vpc_id                    # VPC ID
terraform output cloudwatch_dashboard_name # Dashboard name
terraform output cloudwatch_alarm_arns     # Map of alarm ARNs
```

## Production Checklist

Before deploying to production:

- [ ] Set `single_nat_gateway = false` for high availability
- [ ] Restrict `allowed_cidr_blocks` to specific IP ranges
- [ ] Configure `alarm_actions` with SNS topic for notifications
- [ ] Enable `enable_rotation = true` for password rotation
- [ ] Review and adjust alarm thresholds for your workload
- [ ] Test backup and restore procedures
- [ ] Document runbooks for common operations
- [ ] Set up additional cross-region backups if needed
- [ ] Configure maintenance windows appropriately
- [ ] Review and adjust RDS instance class for your workload

## License

MIT License - See LICENSE file for details.

