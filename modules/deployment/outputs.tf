output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "rds_instance_id" {
  value = module.rds.db_instance_id
}

output "rds_instance_arn" {
  value = module.rds.db_instance_arn
}

output "rds_port" {
  value = module.rds.db_instance_port
}

output "db_username" {
  value     = var.db_master_username
  sensitive = true
}

output "db_password" {
  value     = module.secrets.db_password
  sensitive = true
}

output "secret_arn" {
  value = module.secrets.secret_arn
}

output "rds_security_group_id" {
  value = module.rds.security_group_id
}

output "cloudwatch_log_groups" {
  value = ["error", "agent"]
}

output "connection_info" {
  value = {
    endpoint = module.rds.db_instance_endpoint
    port     = module.rds.db_instance_port
    username = module.rds.master_username
    database = "master"
  }
  sensitive = true
}

output "cloudwatch_dashboard_name" {
  value       = module.monitoring.dashboard_name
  description = "Name of the CloudWatch dashboard"
}

output "cloudwatch_alarm_arns" {
  value       = module.monitoring.alarm_arns
  description = "ARNs of CloudWatch alarms"
}
