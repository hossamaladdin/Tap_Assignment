output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.rds.db_instance_id
}

output "rds_instance_arn" {
  description = "RDS ARN"
  value       = module.rds.db_instance_arn
}

output "rds_port" {
  description = "RDS port"
  value       = module.rds.db_instance_port
}

output "db_secret_arn" {
  description = "Database secret ARN"
  value       = module.secrets.secret_arn
}

output "db_secret_name" {
  description = "Database secret name"
  value       = module.secrets.secret_name
}

# Security Group Outputs
output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = module.rds.security_group_id
}

output "connection_info" {
  description = "RDS connection info"
  value = {
    endpoint        = module.rds.db_instance_endpoint
    port            = module.rds.db_instance_port
    secret_arn      = module.secrets.secret_arn
    security_group  = module.rds.security_group_id
  }
  sensitive = true
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups"
  value       = module.rds.cloudwatch_log_groups
}
