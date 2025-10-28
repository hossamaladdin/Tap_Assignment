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

## Backend Configuration (Remote State on S3)

Configure your `backend.tf` for workspace-based remote state:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-hossam-2025" # Use your unique bucket name
    workspace_key_prefix = "sql-rds"
    region = "us-east-1"
  }
}
```

**How it works:**
- Each workspace (dev, staging, production) uses its own state file in S3: `sql-rds/<workspace>/terraform.tfstate`.
- No need for multiple backend files or manual state moves.
- Use `terraform workspace select <env>` to switch environments.

## Environments

Three environments are supported: `dev`, `staging`, and `production`. Each environment is selected by using its corresponding workspace and tfvars file:

- `dev.tfvars` for development
- `staging.tfvars` for staging
- `prod.tfvars` for production

To deploy a specific environment, run:

```bash
terraform workspace select dev
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```
Replace `dev` and `dev.tfvars` with `staging`/`staging.tfvars` or `production`/`prod.tfvars` as needed.

### tfvars Files
Contain only the environment name (e.g., `environment = "dev"`).

## DynamoDB State Locking (Recommended)

To prevent concurrent state changes, add DynamoDB locking to your backend config:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-hossam-2025"
    workspace_key_prefix = "sql-rds"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}
```
- Create the DynamoDB table manually or with Terraform. The table must have a primary key named `LockID` (type: String).
- This ensures safe, concurrent operations in team environments.

For advanced configuration, see [docs/advanced.md](docs/advanced.md).

