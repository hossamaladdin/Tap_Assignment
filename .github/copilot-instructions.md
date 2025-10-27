# Copilot Instructions for Tap Assignment

## Project Architecture

This is a Terraform project for deploying AWS RDS SQL Server with environment-aware configuration. The architecture uses:

- **Modular design**: Four core modules (`vpc`, `rds`, `iam`, `secrets`) orchestrated by root `main.tf`
- **Environment-based locals**: Intelligence lives in `main.tf` `locals` block, which dynamically configures resources based on environment detection
- **State isolation**: Separate `.tfstate` files per environment (not workspaces) - see deployment commands below

## Critical Environment Logic

The `main.tf` locals block is the heart of environment configuration:

```terraform
locals {
  environment = terraform.workspace == "default" ? "dev" : terraform.workspace
  is_prod = contains(["prod", "production"], lower(local.environment))
  is_staging = contains(["stage", "staging", "test"], lower(local.environment))
  is_dev = !local.is_prod && !local.is_staging
  
  env_config = {
    # Instance sizing, Multi-AZ, backup retention, deletion protection, etc.
  }
}
```

When modifying environment behavior:
- **Never hardcode** environment-specific values in modules
- Add configuration to `env_config` map in `main.tf` locals
- Use ternary operators for 3-tier logic: `prod ? X : (staging ? Y : Z)`

## Deployment Workflow

**Critical**: Use `-var-file` + `-state` pattern, NOT workspaces alone:

```bash
# Development
terraform plan -var-file="terraform-dev.tfvars" -state="dev.tfstate"
terraform apply -var-file="terraform-dev.tfvars" -state="dev.tfstate"

# Production
terraform plan -var-file="terraform-production.tfvars" -state="production.tfstate"
terraform apply -var-file="terraform-production.tfvars" -state="production.tfstate"
```

**Why this matters**: Without explicit `-state` flags, all environments share `terraform.tfstate`, causing one environment to destroy another.

## Snapshot & Deletion Behavior

Environment-specific destruction behavior is defined in `env_config`:

- **Dev**: `skip_final_snapshot = true`, `delete_automated_backups = true` (fast, clean teardown)
- **Staging**: `skip_final_snapshot = false`, `delete_automated_backups = true` (final snapshot kept)
- **Production**: `skip_final_snapshot = false`, `delete_automated_backups = false` (maximum data retention)

When adding new boolean flags, follow this pattern in `env_config`.

## Module Communication Pattern

Modules receive **all** configuration from root `main.tf` - they don't compute environment logic:

```terraform
module "rds" {
  source = "./modules/rds"
  
  instance_class = local.env_config.instance_class  # From locals, not module defaults
  multi_az = local.env_config.multi_az
  # ... all env-specific values
}
```

**Module variables** have defaults only for documentation/optional features. Required environment behavior comes from root.

## Security & IAM Structure

- **RDS Monitoring**: `modules/iam` creates role for Enhanced Monitoring (required when `monitoring_interval > 0`)
- **Secrets Access**: EC2 instance profile for Secrets Manager access (demonstrates pattern, not currently used by RDS module)
- **Password Management**: `random_password` in `modules/rds/main.tf` with `lifecycle.ignore_changes = [password]` to prevent rotation on every apply

## VPC & Networking

- **S3 VPC Endpoint**: Gateway endpoint configured in `modules/vpc/main.tf` to avoid NAT Gateway costs for S3 traffic
- **Flow Logs**: Automatically enabled for all VPCs, sent to CloudWatch with 7-day retention
- **Subnet Strategy**: Private subnets for RDS (across multiple AZs), public subnets for NAT Gateways

## SQL Server Specifics

- **Engine**: `sqlserver-se` (Standard Edition) version `15.00.4335.1.v1`
- **Parameter Group**: Custom tuning in `modules/rds/main.tf`:
  - `contained database authentication = 1`
  - `cost threshold for parallelism = 50`
  - `max degree of parallelism = 4`
  - `optimize for ad hoc workloads = 1`
- **Port**: 1433 (hardcoded in security group rules)
- **CloudWatch Logs**: Exports `error` and `agent` logs by default

## Storage Tiers

Storage configuration scales with environment (defined in `env_config`):

- **Dev**: `gp3` storage (125 IOPS default throughput)
- **Staging**: `gp3` storage
- **Production**: `io1` storage with explicit IOPS (2500 for 500GB = 5 IOPS/GB)

When modifying storage: `io1` **requires** `iops` parameter, `gp3` uses `storage_throughput` (optional).

## Lifecycle & Timeouts

RDS resources use extended timeouts (`90m` create/update/delete) due to SQL Server provisioning time. The `final_snapshot_identifier` uses `timestamp()` and is in `lifecycle.ignore_changes` to prevent forced replacement.

## Tags Strategy

Tags propagate from root via `default_tags` in `providers.tf` and merged `local.common_tags`:

```terraform
default_tags {
  tags = {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
```

Module resources merge with `merge(var.tags, { Name = "..." })` pattern.

## File Organization

```
main.tf              # Root orchestration + environment logic
variables.tf         # Minimal root variables (project_name, region, etc.)
outputs.tf           # Exposes module outputs + sensitive connection_info
terraform-{env}.tfvars  # Environment-specific variable values
modules/
  vpc/              # Network infrastructure + S3 endpoint
  rds/              # SQL Server instance + parameter/option groups
  iam/              # Monitoring role + secrets access role
  secrets/          # (Not currently used, prepared for future)
```

## Common Modifications

**Add new environment tier**: Update `locals.env_config` map with new conditional logic  
**Change RDS parameters**: Edit `aws_db_parameter_group.sqlserver` in `modules/rds/main.tf`  
**Adjust backup windows**: Modify `backup_window`/`maintenance_window` in `terraform-{env}.tfvars` or module defaults  
**Add security group rules**: Use `aws_security_group_rule` resources in `modules/rds/main.tf` (count-based for CIDR, loop for SG IDs)

## Backend Configuration

Currently uses `backend "local"` in `versions.tf`. To enable remote state:

1. Replace `backend "local" {}` with S3/Terraform Cloud configuration
2. Run `terraform init -migrate-state` for each environment state file
3. Update deployment commands to remove `-state` parameter (backend handles it)
