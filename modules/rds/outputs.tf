output "db_instance_id" {
  value = aws_db_instance.sqlserver.id
}

output "db_instance_arn" {
  value = aws_db_instance.sqlserver.arn
}

output "db_instance_endpoint" {
  value = aws_db_instance.sqlserver.endpoint
}

output "db_instance_address" {
  value = aws_db_instance.sqlserver.address
}

output "db_instance_port" {
  value = aws_db_instance.sqlserver.port
}

output "security_group_id" {
  value = aws_security_group.rds.id
}

output "master_username" {
  value = var.master_username
}

output "master_password" {
  value     = var.master_password
  sensitive = true
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}

output "db_parameter_group_name" {
  value = aws_db_parameter_group.sqlserver.name
}

output "db_option_group_name" {
  description = "Name of the DB option group"
  value       = aws_db_option_group.sqlserver.name
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for RDS"
  value       = var.enabled_cloudwatch_logs_exports
}

output "availability_zone" {
  value = aws_db_instance.sqlserver.availability_zone
}
