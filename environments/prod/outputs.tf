output "vpc_id" {
  description = "VPC ID"
  value       = module.deployment.vpc_id
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.deployment.rds_endpoint
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.deployment.rds_instance_id
}

output "connection_info" {
  description = "Database connection information"
  value       = module.deployment.connection_info
  sensitive   = true
}
