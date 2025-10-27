# Terraform AWS RDS SQL Server

## Usage Options

### Option 1: Simple Commands (One Environment at a Time)
```bash
terraform init

# Deploy any environment (replaces previous)
terraform apply -var="environment=dev"
terraform apply -var="environment=staging"  
terraform apply -var="environment=production"

# Destroy current environment
terraform destroy -var="environment=<current-env>"
```

### Option 2: Multiple Environments (Separate State Files)
```bash
terraform init

# Deploy multiple environments simultaneously 
terraform apply -var="environment=dev" -state="states/dev.tfstate"
terraform apply -var="environment=staging" -state="states/staging.tfstate"
terraform apply -var="environment=production" -state="states/production.tfstate"

# Destroy specific environment
terraform destroy -var="environment=dev" -state="states/dev.tfstate"
```

### Option 3: Auto-Workspaces (Recommended for Parallel)
```bash
terraform init

# Create workspaces for each environment (one-time setup)
terraform workspace new dev
terraform workspace new staging
terraform workspace new production

# Deploy in parallel - each command in separate terminal
terraform workspace select dev && terraform apply -var="environment=dev"
terraform workspace select staging && terraform apply -var="environment=staging"  
terraform workspace select production && terraform apply -var="environment=production"

# Or deploy sequentially
terraform workspace select dev && terraform apply -var="environment=dev"
terraform workspace select staging && terraform apply -var="environment=staging"
```

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