# Terraform AWS RDS SQL Server

Provision a high-availability SQL Server (Standard Edition) RDS deployment on AWS. All environments (dev, staging, prod) use the same configuration—only the environment name/tag changes.

## Simple Workflow: Workspace-based Remote State
For seamless environment switching using Terraform workspaces and S3 remote state:

```bash
# Initialize backend and select workspace
terraform init -reconfigure
terraform workspace new dev || terraform workspace select dev
terraform plan -var="environment=dev"
terraform apply -var="environment=dev"

# Switch to production
terraform workspace new production || terraform workspace select production
terraform plan -var="environment=production"
terraform apply -var="environment=production"

# Switch to staging
terraform workspace new staging || terraform workspace select staging
terraform plan -var="environment=staging"
terraform apply -var="environment=staging"
```
- Each workspace uses its own state file in S3: `sql-rds/<workspace>/terraform.tfstate`
- No manual state file moves required—just switch workspaces and run plan/apply.
- Make sure your S3 bucket and backend config are set up as described below.

## Quickstart

```bash
terraform init
terraform apply -var-file="dev.tfvars" -state="dev.tfstate"
```

Use a separate state file for each environment to prevent overlap. If you omit `-state`, environments will overwrite each other.

## Environments

Three environments are supported: `dev`, `staging`, and `prod`. Each environment is selected by using its corresponding tfvars file:

- `dev.tfvars` for development
- `staging.tfvars` for staging
- `prod.tfvars` for production

To deploy a specific environment, run:

```bash
terraform apply -var-file="<env>.tfvars" -state="<env>.tfstate"
```
Replace `<env>` with `dev`, `staging`, or `prod` as needed.

### tfvars Files
Contain only the environment name (e.g., `environment = "dev"`).


## Backend Configuration (Remote State on S3)

To use remote state with S3 for multiple environments, configure your `backend.tf` as follows:

```hcl
terraform {
	backend "s3" {
		bucket = "terraform-state-hossam-2025" # Use your unique bucket name
		key    = "sql-rds/${var.environment}/terraform.tfstate" # Environment-specific key
		region = "us-east-1"
	}
}
```

**How it works:**
- The `${var.environment}` variable is set via your tfvars files (`dev.tfvars`, `staging.tfvars`, `prod.tfvars`).
- This keeps state files separate for each environment, all in the same bucket.
- You only need one `backend.tf` file. Terraform will use the correct key based on the environment variable you pass when running `terraform plan/apply` with `-var-file="dev.tfvars"` (or staging/prod).

**No need to create multiple backend files—just use the variable in the key.**

After apply, Terraform will output the RDS endpoint, master username, and secret ARN for connection.

For advanced configuration, see [docs/advanced.md](docs/advanced.md).

## Using a single backend config and Terraform workspaces

If you prefer a single file and minimal CLI flags, add a small `backend.conf` containing shared backend settings (bucket and region). Then override only the `key` per environment during init.

Example `backend.conf` (already added to the repo):
```
bucket = "terraform-state-hossam-2025"
region = "us-east-1"
```

Initialize staging (overrides only the key):
```bash
terraform init -reconfigure -backend-config=backend.conf \
	-backend-config="key=sql-rds/staging/terraform.tfstate"
terraform workspace new staging || terraform workspace select staging
terraform plan -var="environment=staging"
terraform apply -var="environment=staging"
```

Notes about workspaces and migration:
- Backend blocks cannot use input variables, so do not use `${var.environment}` in `backend.tf`.
- Using `terraform.workspace` is an alternative (set workspace names to `dev`, `staging`, `prod`). If you choose that, update `backend.tf` to use the workspace name in the key and then run `terraform init -reconfigure` once.
- If you have an existing local `dev.tfstate` or different state layout, migrate it by initializing with the dev key and allowing Terraform to copy local state to S3, or use `-force-copy` for non-interactive moves.

