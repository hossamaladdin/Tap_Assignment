output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.sqlserver.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.sqlserver.arn
}

output "db_instance_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = aws_db_instance.sqlserver.endpoint
}

output "db_instance_address" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.sqlserver.address
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.sqlserver.port
}

output "security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "master_username" {
  description = "Master username for the RDS instance"
  value       = aws_db_instance.sqlserver.username
}

output "master_password" {
  description = "Master password for the RDS instance"
  value       = random_password.master.result
  sensitive   = true
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "db_parameter_group_name" {
  description = "Name of the DB parameter group"
  value       = aws_db_parameter_group.sqlserver.name
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
  description = "Availability zone of the RDS instance"
  value       = aws_db_instance.sqlserver.availability_zone
}
