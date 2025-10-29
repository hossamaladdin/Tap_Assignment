# Copilot Instructions for Tap Assignment

## Project Architecture - UNIFIED STRUCTURE

This is a Terraform project for deploying AWS RDS SQL Server with **unified configuration across all environments**.

### Key Principle
**One configuration, multiple environments** - only the environment tag/name changes between deployments.

## Project Structure

```
.
├── main.tf              # Single deployment configuration
├── variables.tf         # Input variables (environment is the main variable)
├── provider.tf          # AWS provider configuration
├── versions.tf          # Terraform and provider versions
├── backend.tf           # State backend configuration
├── outputs.tf           # Output definitions
├── dev.tfvars          # Dev environment (just sets environment="dev")
├── staging.tfvars      # Staging environment (just sets environment="staging")
├── prod.tfvars         # Production environment (just sets environment="prod")
└── modules/
    ├── deployment/     # Orchestration module
    ├── vpc/           # Network infrastructure
    ├── rds/           # SQL Server instance
    ├── iam/           # IAM roles
    └── secrets/       # Secrets Manager (not currently used)
```

## Deployment Workflow

All environments use the **same configuration**. Deploy with different tfvars files:

```bash
# Development
terraform plan -var-file="dev.tfvars" -state="dev.tfstate"
terraform apply -var-file="dev.tfvars" -state="dev.tfstate"

# Staging
terraform plan -var-file="staging.tfvars" -state="staging.tfstate"
terraform apply -var-file="staging.tfvars" -state="staging.tfstate"

# Production
terraform plan -var-file="prod.tfvars" -state="prod.tfstate"
terraform apply -var-file="prod.tfvars" -state="prod.tfstate"
```

## Unified Configuration

All environments share the same RDS specs (defined in `main.tf`):
- Instance Class: `db.m5.large`
- Multi-AZ: `true`
- Storage: `100GB gp3` (auto-scaling to 200GB)
- Backup Retention: `7 days`
- SQL Server Standard Edition

**The only difference** between environments is the `environment` variable, which affects:
- Resource naming (e.g., `tap-assignment-dev-vpc`, `tap-assignment-prod-rds`)
- Environment tag value

## Module Architecture

### Deployment Module (`modules/deployment`)
- Orchestrates VPC, RDS, and IAM modules
- Accepts all configuration as variables
- No environment-specific logic

### Core Infrastructure Modules
- **vpc**: Network + NAT Gateways + S3 VPC Endpoint + Flow Logs
- **rds**: SQL Server instance with parameter/option groups
- **iam**: RDS monitoring role + EC2 secrets access role
- **secrets**: Prepared for future use

## NAT Gateway Configuration

Currently creates **3 NAT Gateways** (one per AZ) which:
- Requires 3 Elastic IPs per environment
- Can hit AWS EIP limits when deploying multiple environments
- Consider reducing to 1 NAT Gateway for cost savings

## Security & IAM
- RDS Enhanced Monitoring role (when monitoring_interval > 0)
- EC2 instance profile for Secrets Manager access
- Random password generation with lifecycle ignore_changes

## SQL Server Specifics
- Engine: `sqlserver-se` (Standard Edition)
- Custom parameter group with performance tuning
- CloudWatch Logs: error and agent logs
- Port: 1433

## Tags Strategy
Tags propagate from provider `default_tags`:
```terraform
Environment = var.environment  # dev, staging, or prod
Project     = var.project_name # tap-assignment
ManagedBy   = "Terraform"
```

## Common Modifications

**Change RDS configuration for all environments**: Edit `main.tf` module parameters
**Add new variable**: Add to `variables.tf`, update tfvars files if needed
**Adjust NAT gateways**: Modify `modules/vpc/main.tf`
**Add security group rules**: Use `aws_security_group_rule` in `modules/rds/main.tf`

## Backend Configuration

Currently uses `backend "local"` with separate state files per environment (via `-state` flag).

For production, configure remote state in `backend.tf`:
```terraform
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "tap-assignment/${var.environment}/terraform.tfstate"
    region = "us-east-1"
  }
}
```
