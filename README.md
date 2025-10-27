# Terraform AWS RDS SQL Server

Provision a high-availability, environment-aware SQL Server (Standard Edition) RDS deployment with supporting VPC, IAM, monitoring, and tagging best practices.

## 1. Architecture Overview

Root `main.tf` orchestrates four modules:

| Module | Purpose |
|--------|---------|
| `vpc`  | VPC, subnets (public + private), NAT, flow logs, optional S3 gateway endpoint |
| `iam`  | Enhanced monitoring role + EC2 instance profile & policy for future secrets consumption |
| `rds`  | DB subnet group, security group, parameter + option groups, RDS instance |
| `secrets` | (Optional) Secrets Manager storage for credentials (not wired yet) |

All environment-specific decisions live in the `locals { env_config = { ... } }` block of `main.tf` (instance sizing, HA, retention, deletion protection, snapshot behavior). Modules DO NOT compute environment logic themselves.

## 2. Environment Management (tfvars + explicit state)

Use separate state files per environment to prevent destructive overlap:

```bash
terraform init

# Development
terraform plan  -var-file="terraform-dev.tfvars"        -state="dev.tfstate"
terraform apply -var-file="terraform-dev.tfvars"        -state="dev.tfstate"

# Staging
terraform plan  -var-file="terraform-staging.tfvars"    -state="staging.tfstate"
terraform apply -var-file="terraform-staging.tfvars"    -state="staging.tfstate"

# Production
terraform plan  -var-file="terraform-production.tfvars" -state="production.tfstate"
terraform apply -var-file="terraform-production.tfvars" -state="production.tfstate"
```

If you omit `-state`, all applies share `terraform.tfstate` and environments will overwrite one another.

### tfvars Files
Contain only per-environment overrides (CIDR allow-list, etc.). All strategic behavior stays in `locals.env_config`.

## 3. Environment Profiles

| Env | HA | Storage | Backups | Snapshot Destroy Behavior | Instance Class |
|-----|----|---------|---------|---------------------------|----------------|
| dev | Single-AZ | gp3 | 3 days | Skip final snapshot + delete automated backups | db.m5.large |
| staging | Multi-AZ | gp3 | 7 days | Keep final snapshot, delete automated backups | db.m5.xlarge |
| production | Multi-AZ | io1 (2500 IOPS) | 14 days | Keep final + keep automated backups | db.m5.2xlarge |

Values derived via ternary pattern: `prod ? X : (staging ? Y : Z)`.

## 4. Snapshot & Deletion Protection Logic

Defined in `env_config`:
- Dev: Fast teardown (`skip_final_snapshot = true`, `delete_automated_backups = true`)
- Staging: Preserve final snapshot, drop automated backups
- Production: Preserve both final snapshot and automated backups; `deletion_protection = true`

`final_snapshot_identifier` uses a timestamp and is ignored for future changes (prevents forced replacement).

## 5. Security & Access

- Security group restricts ingress on port 1433 to allowed CIDRs (or SG IDs if provided).
- Enhanced Monitoring: IAM role from `iam` module attached when `monitoring_interval > 0`.
- Password generated with `random_password` and ignored on change to maintain idempotency.
- Optional KMS: `kms_key_id` variable (null by default) lets you supply a customer-managed key without impacting existing state.

## 6. Networking Features

- Private subnets host RDS; public subnets host NAT gateways.
- S3 Gateway endpoint (optional) reduces NAT data transfer cost and keeps traffic on AWS backbone.
- Flow logs sent to CloudWatch (7-day retention) for auditing.

## 7. SQL Server Specific Configuration

# Tap Assignment — Terraform AWS RDS SQL Server

Quickstart: get a development RDS SQL Server deployed in ~2 minutes.

## Quickstart
1. Initialize Terraform

```bash
terraform init
```

2. Plan & apply for development (uses local backend/state file pattern):

```bash
terraform plan  -var-file="terraform-dev.tfvars" -state="dev.tfstate"
terraform apply -var-file="terraform-dev.tfvars" -state="dev.tfstate"
```

3. After apply, view outputs (endpoint, port, sensitive connection bundle):

```bash
terraform output connection_info
```

## What this repo contains
- `main.tf` root orchestration + `locals.env_config` (environment logic)
- `modules/`:
	- `vpc/` — VPC, subnets, NAT, flow logs, optional S3 gateway endpoint
	- `rds/` — DB subnet group, parameter/option groups, security group, RDS instance
	- `iam/` — Enhanced monitoring role + secrets access profile
	- `secrets/` — Optional Secrets Manager pattern (not wired by default)
- `terraform-*.tfvars` — environment variable overrides
- `providers.tf`, `versions.tf`, `outputs.tf`, `variables.tf`

## Architecture (short)
Root `main.tf` computes `local.environment` and populates `local.env_config` which contains all environment-specific values (instance sizes, multi-AZ, backup retention, storage type). Modules receive precomputed values from root; modules are intentionally environment-agnostic.

## Where to find advanced docs
The previous detailed README content (examples, secrets wiring, bastion, CI, remote backend guidance, and debugging material) moved to `docs/advanced.md`.

## Next steps & suggestions
- Review `terraform-*.tfvars` before applying to avoid exposing wide CIDRs.
- Consider enabling a remote backend (S3 + DynamoDB) for team use; samples are in `docs/advanced.md`.


---

For full documentation and optional examples, see `docs/advanced.md`.
