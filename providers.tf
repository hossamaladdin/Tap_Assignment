provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = local.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
