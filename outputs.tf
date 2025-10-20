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

output "rds_master_username" {
  description = "Master username for RDS"
  value       = var.db_master_username
  sensitive   = true
}

output "rds_database_name" {
  description = "Name of the initial database"
  value       = var.db_name
}

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

# Bastion Outputs
output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = var.enable_bastion ? module.bastion[0].bastion_public_ip : null
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = var.enable_bastion ? module.bastion[0].bastion_instance_id : null
}

# Connection Information
output "connection_info" {
  description = "Connection information for the RDS instance"
  value = {
    endpoint        = module.rds.db_instance_endpoint
    port            = module.rds.db_instance_port
    username        = var.db_master_username
    database        = var.db_name
    secret_arn      = module.secrets.secret_arn
    security_group  = module.rds.security_group_id
  }
  sensitive = false
}

# CloudWatch Log Groups
output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for RDS"
  value       = module.rds.cloudwatch_log_groups
}
