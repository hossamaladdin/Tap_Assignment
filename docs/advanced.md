````markdown
# Terraform AWS RDS SQL Server — Advanced Documentation

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

- Engine: `sqlserver-se` version `15.00.4335.1.v1`
- Parameter group tuning:
    - `contained database authentication = 1`
    - `cost threshold for parallelism = 50`
    - `max degree of parallelism = 4`
    - `optimize for ad hoc workloads = 1`
- CloudWatch log exports: `error`, `agent`
- Port: 1433 (fixed in SG rules)

## 8. Storage Strategy

- Dev/Staging: `gp3` (conditional `storage_throughput` applied only when gp3)
- Production: `io1` (explicit IOPS = 5 × allocated storage GB)
    - IOPS logic currently set to 2500 for 500GB

## 9. Tagging Convention

Provider `default_tags` + `local.common_tags` ensure uniform tagging (`Environment`, `Project`, `ManagedBy`). Each resource merges module-specific `Name` tag.

## 10. Validations & Guardrails

Input validation enforces:
- `project_name` lowercase/hyphen
- `aws_region` pattern
- `allowed_cidr_blocks` IPv4 CIDR format

## 11. Outputs

Key outputs include endpoint, port, instance identifiers, security group ID, and sensitive connection bundle (`connection_info`).

## 12. Optional & Extensible Features (Not Enabled by Default)

| Feature | Status | How to Enable |
|---------|--------|---------------|
| Secrets Manager integration of live endpoint | Not wired | Add secrets module call + update secret version with endpoint / port |
| Customer-managed KMS key | Available (null default) | Set `kms_key_id` in root or tfvars |
| Bastion/EC2 connectivity example | Not present | Add small EC2 instance in public subnet with tools installed |
| Performance Insights longer retention | Fixed 7 days | Make retention environment-aware in `env_config` |
| CI (fmt/validate/tflint) | Absent | Add GitHub Action workflow |
| Remote state (S3 + DynamoDB) | Local backend now | Replace backend in `versions.tf` + migrate state |

### Sample: Wire Secrets Module
```terraform
module "secrets" {
    source             = "./modules/secrets"
    name_prefix        = local.name_prefix
    db_master_username = module.rds.master_username
    db_master_password = module.rds.master_password
    tags               = local.common_tags
}

resource "aws_secretsmanager_secret_version" "rds_connection_metadata" {
    secret_id = module.secrets.db_credentials_secret_id
    secret_string = jsonencode({
        username = module.rds.master_username
        password = module.rds.master_password
        host     = module.rds.db_instance_endpoint
        port     = module.rds.db_instance_port
        engine   = "sqlserver"
    })
    lifecycle { ignore_changes = [secret_string] }
}
```

### Sample: Bastion EC2
```terraform
resource "aws_instance" "bastion" {
    ami           = var.bastion_ami_id
    instance_type = "t3.micro"
    subnet_id     = module.vpc.public_subnet_ids[0]
    vpc_security_group_ids = [module.rds.security_group_id]
    tags = merge(local.common_tags, { Name = "${local.name_prefix}-bastion" })
    user_data = <<-EOF
#!/bin/bash
yum install -y mssql-tools unixODBC
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/profile
EOF
}
```

### Sample: GitHub Action (terraform fmt + validate)
```yaml
name: terraform-ci
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.7.5
      - name: Init
        run: terraform init -backend=false
      - name: Format Check
        run: terraform fmt -recursive -check
      - name: Validate
        run: terraform validate
```

### Sample: Remote Backend Migration (S3)
```terraform
terraform {
    backend "s3" {
        bucket         = "my-tf-state-bucket"
        key            = "tap-sqlserver/${local.environment}.tfstate"
        region         = var.aws_region
        dynamodb_table = "terraform-locks"
        encrypt        = true
    }
}
```
Then run per environment:
```bash
terraform init -migrate-state -var-file=terraform-dev.tfvars
```

## 13. Future Improvements (Roadmap)

1. Secrets integration & removal of duplicate password generation
2. Environment-aware Performance Insights retention (prod ≥ 93 days)
3. Conditional IAM monitoring resources when `monitoring_interval == 0`
4. for_each-based SG CIDR ingress for granular audit diffs
5. Tagging expansion: cost center / data classification

## 14. Troubleshooting Cheatsheet

| Symptom | Likely Cause | Action |
|---------|--------------|--------|
| Prod apply wants to recreate DB | Changed immutable property (e.g., engine major) | Revert or plan maintenance window replacement |
| Password diff every plan | Missing `lifecycle.ignore_changes` (already present) | Confirm block intact |
| No logs in CloudWatch | `monitoring_interval` set too high or role missing | Check IAM role ARN output |
| gp3 throughput ignored | `storage_type` not gp3 | Verify env_config storage_type |

````
