# Copilot Instructions for Tap Assignment

## Project Architecture

This is a Terraform project for deploying AWS RDS SQL Server with **per-environment configuration**. The architecture uses:

- **Modular design**: Five core modules (`vpc`, `rds`, `iam`, `secrets`, `deployment`) with environment-specific wrappers
- **Per-environment directories**: Each environment (`dev`, `staging`, `prod`) has its own directory with backend, provider, and configuration
- **State isolation**: Separate backends per environment directory - no workspace switching needed
- **Clean separation**: The `deployment` module is generic; environment-specific values live in `environments/*/main.tf`

## Environment Structure

Each environment directory contains:
- `backend.tf` - Local backend configuration (state file path)
- `versions.tf` - Terraform and provider version requirements
- `provider.tf` - AWS provider configuration with environment tags
- `variables.tf` - Input variable declarations
- `terraform.tfvars` - Environment-specific variable values
- `main.tf` - Module call with **all environment-specific RDS configuration**
- `outputs.tf` - Output definitions

**Key principle**: Environment configuration lives in `environments/{env}/main.tf`, not in the deployment module.

## Deployment Workflow

Deploy from the environment directory (no `-var-file` or `-state` flags needed):

```bash
# Development
cd environments/dev
terraform init
terraform plan
terraform apply

# Production
cd environments/prod
terraform init
terraform plan
terraform apply
```

Each environment manages its own state file automatically via `backend.tf`.

## Module Architecture

### Deployment Module (`modules/deployment`)

Generic orchestration module that:
- Accepts **all configuration as variables** (no environment detection logic)
- Calls the core infrastructure modules (vpc, rds, iam, secrets)
- Uses `var.environment` for naming and tagging only

**Critical**: The deployment module does NOT contain environment-specific logic. It's a pass-through orchestrator.

### Core Infrastructure Modules

- **vpc**: Network infrastructure + S3 VPC endpoint + Flow Logs
- **rds**: SQL Server instance with parameter/option groups
- **iam**: RDS Enhanced Monitoring role + Secrets Manager access
- **secrets**: (Prepared for future RDS endpoint storage)

## Environment Configuration Pattern

Environment-specific settings are defined directly in `environments/{env}/main.tf`:

```terraform
module "deployment" {
  source = "../../modules/deployment"
  
  environment = "prod"  # or "dev", "staging"
  
  # Production-specific values
  instance_class = "db.m5.2xlarge"
  multi_az = true
  storage_type = "io1"
  iops = 2500
  # ... etc
}
```

**Never add conditional logic** based on environment to the deployment module. Add the configuration to the environment wrapper instead.

## Snapshot & Deletion Behavior

Environment-specific destruction behavior is configured in each environment's `main.tf`:

- **Dev** (`environments/dev/main.tf`): `skip_final_snapshot = true`, `delete_automated_backups = true` (fast, clean teardown)
- **Staging** (`environments/staging/main.tf`): `skip_final_snapshot = false`, `delete_automated_backups = true` (final snapshot kept)
- **Production** (`environments/prod/main.tf`): `skip_final_snapshot = false`, `delete_automated_backups = false` (maximum data retention)

To change behavior: edit the environment's `main.tf` module call.

## Adding New Environments or Modifying Configuration

**Add new environment tier**:
1. Copy an existing `environments/{env}` directory
2. Update `backend.tf` with new state file path
3. Modify `main.tf` module call with environment-specific values
4. Update `terraform.tfvars` as needed

**Change RDS configuration for an environment**:
- Edit `environments/{env}/main.tf` module call parameters
- Do NOT modify the `modules/deployment` module

**Add new infrastructure**:
- Add to appropriate core module (`vpc`, `rds`, `iam`, `secrets`)
- Wire through `modules/deployment` if needed
- Pass configuration from environment wrappers

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
environments/
  dev/
    backend.tf           # Local backend: ../../dev.tfstate
    versions.tf          # Terraform/provider requirements
    provider.tf          # AWS provider config
    variables.tf         # Input variables
    terraform.tfvars     # Dev-specific values
    main.tf             # Module call with dev RDS config
    outputs.tf          # Output definitions
  staging/
    (same structure as dev)
  prod/
    (same structure as dev)
modules/
  deployment/          # Orchestration module (no env logic)
    main.tf
    variables.tf
    outputs.tf
  vpc/                # Network infrastructure + S3 endpoint
  rds/                # SQL Server instance + parameter/option groups
  iam/                # Monitoring role + secrets access role
  secrets/            # (Not currently used, prepared for future)
```

## Common Modifications

**Change environment RDS config**: Edit `environments/{env}/main.tf` module parameters  
**Adjust RDS parameters**: Edit `aws_db_parameter_group.sqlserver` in `modules/rds/main.tf`  
**Add security group rules**: Use `aws_security_group_rule` resources in `modules/rds/main.tf`  
**Add new module variable**: Add to `modules/deployment/variables.tf` and pass from environment wrappers

## Backend Configuration

Currently uses `backend "local"` in `versions.tf`. To enable remote state:

1. Replace `backend "local" {}` with S3/Terraform Cloud configuration
2. Run `terraform init -migrate-state` for each environment state file
3. Update deployment commands to remove `-state` parameter (backend handles it)
