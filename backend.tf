# Local backend - use separate state files per environment
# Usage:
#   terraform apply -var-file="dev.tfvars" -state="dev.tfstate"
#   terraform apply -var-file="staging.tfvars" -state="staging.tfstate"
#   terraform apply -var-file="prod.tfvars" -state="prod.tfstate"

terraform {
  backend "local" {}
}

# For production, use remote state with S3 backend:
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "tap-assignment/${var.environment}/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
