terraform {
  backend "s3" {
    bucket = "terraform-state-hossam-2025"
    workspace_key_prefix = "sql-rds"
    region = "us-east-1"
  }
}