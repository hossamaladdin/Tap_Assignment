output "vpc_id" {
  value = module.deployment.vpc_id
}

output "rds_instance_id" {
  value = module.deployment.rds_instance_id
}

output "rds_endpoint" {
  value       = module.deployment.rds_endpoint
  description = "RDS endpoint"
}

output "master_username" {
  value       = module.deployment.db_username
  sensitive   = true
  description = "Master username"
}

output "secret_arn" {
  value       = module.deployment.secret_arn
  description = "Secret ARN in Secrets Manager"
}

output "connection_info" {
  value     = module.deployment.connection_info
  sensitive = true
}
