# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.rds.db_instance_id
}

output "rds_instance_arn" {
  description = "RDS instance ARN"
  value       = module.rds.db_instance_arn
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

# Removed sensitive outputs as they are included in secrets

# Secrets Manager Outputs
output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret for database credentials"
  value       = module.secrets.secret_arn
}

output "db_secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = module.secrets.secret_name
}

# Security Group Outputs
output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = module.rds.security_group_id
}

# Connection Information
output "connection_info" {
  description = "Connection information for the RDS instance"
  value = {
    endpoint        = module.rds.db_instance_endpoint
    port            = module.rds.db_instance_port
    secret_arn      = module.secrets.secret_arn
    security_group  = module.rds.security_group_id
  }
  sensitive = true
}

# CloudWatch Log Groups
output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for RDS"
  value       = module.rds.cloudwatch_log_groups
}
