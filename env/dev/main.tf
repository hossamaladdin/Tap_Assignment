# Backend Configuration for Dev Environment
terraform {
  backend "s3" {
    bucket  = "tap-assignment-tfstate"
    key     = "dev/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# Deployment Module
module "deployment" {
  source = "../../modules/deployment"

  # Environment Configuration
  project_name = var.project_name
  environment  = "dev"

  # AWS Configuration
  aws_region = var.aws_region

  # RDS Configuration
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_type            = var.storage_type
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection

  # Security Configuration
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  skip_final_snapshot        = var.skip_final_snapshot
  delete_automated_backups   = var.delete_automated_backups
  allowed_cidr_blocks        = var.allowed_cidr_blocks

  # Network Configuration
  single_nat_gateway = var.single_nat_gateway
  enable_s3_endpoint = var.enable_s3_endpoint

  # Database Configuration
  db_master_username = var.db_master_username

  # Secrets Management
  enable_rotation     = var.enable_rotation
  rotation_lambda_arn = var.rotation_lambda_arn
  rotation_days       = var.rotation_days

  # Monitoring Configuration
  alarm_actions         = var.alarm_actions
  cpu_threshold         = var.cpu_threshold
  memory_threshold      = var.memory_threshold
  storage_threshold     = var.storage_threshold
  connections_threshold = var.connections_threshold
  latency_threshold     = var.latency_threshold
}

# Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.deployment.rds_endpoint
}

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = module.deployment.rds_instance_id
}

output "secret_arn" {
  description = "Secrets Manager ARN for database credentials"
  value       = module.deployment.secret_arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.deployment.vpc_id
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.deployment.cloudwatch_dashboard_name
}

output "db_username" {
  description = "Database master username"
  value       = var.db_master_username
  sensitive   = true
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.deployment.rds_security_group_id
}
