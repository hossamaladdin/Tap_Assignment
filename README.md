# Terraform AWS RDS SQL Server

## Environment Management with tfvars (Best Practice)

### Single Command Deployment
```bash
terraform init

# Development
terraform plan -var-file="terraform-dev.tfvars" -state="dev.tfstate"
terraform apply -var-file="terraform-dev.tfvars" -state="dev.tfstate"

# Staging
terraform plan -var-file="terraform-staging.tfvars" -state="staging.tfstate"
terraform apply -var-file="terraform-staging.tfvars" -state="staging.tfstate"

# Production
terraform plan -var-file="terraform-production.tfvars" -state="production.tfstate"
terraform apply -var-file="terraform-production.tfvars" -state="production.tfstate"
```

### Environment-Specific Configuration Files
- `terraform-dev.tfvars` - Development settings
- `terraform-staging.tfvars` - Staging settings  
- `terraform-production.tfvars` - Production settings

### What's the S3 VPC Endpoint?
The S3 VPC Endpoint allows secure access to S3 from your VPC without going through the internet gateway:

**Benefits:**
- **Security:** Traffic stays within AWS network
- **Cost:** No NAT Gateway charges for S3 traffic
- **Performance:** Lower latency and higher bandwidth
- **Compliance:** Meets strict network isolation requirements

**How it works:**
- Creates a gateway endpoint in your VPC
- Routes S3 traffic through AWS backbone network
- No internet access required for S3 operations

## Environment Types
- **dev**: Basic performance, single-AZ, minimal backups, **skip snapshots on destroy**
- **staging**: Medium performance, multi-AZ, extended backups, **delete automated backups**  
- **production**: High performance, multi-AZ, full security, **keeps final snapshots**

## Snapshot Management
- **Dev**: `skip_final_snapshot = true` + `delete_automated_backups = true` (fast destroy)
- **Staging**: `skip_final_snapshot = false` + `delete_automated_backups = true` (safer)
- **Production**: `skip_final_snapshot = false` + `delete_automated_backups = false` (maximum protection)

## What Happens Without State Management?
If you run without `-state` parameter, Terraform uses `terraform.tfstate`:
- **Same file for all environments** → environments replace each other
- **Only one environment exists** at any time
- **Simpler for testing**, problematic for real use