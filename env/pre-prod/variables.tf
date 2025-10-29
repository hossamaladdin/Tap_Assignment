# Variables for Dev Environment
# These variables are populated from config.auto.tfvars in the root directory

variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
}

variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "allocated_storage" {
  type        = number
  description = "Initial allocated storage in GB"
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum storage for autoscaling in GB"
}

variable "storage_type" {
  type        = string
  description = "Storage type (gp2, gp3, io1)"
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment"
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Enable automatic minor version upgrades"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on deletion"
}

variable "delete_automated_backups" {
  type        = bool
  description = "Delete automated backups on instance deletion"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access RDS"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use single NAT gateway for cost optimization"
}

variable "enable_s3_endpoint" {
  type        = bool
  description = "Enable S3 VPC endpoint"
}

variable "db_master_username" {
  type        = string
  description = "Master username for RDS"
}

variable "enable_rotation" {
  type        = bool
  description = "Enable automatic password rotation"
}

variable "rotation_lambda_arn" {
  type        = string
  description = "Lambda ARN for password rotation"
  default     = ""
}

variable "rotation_days" {
  type        = number
  description = "Days between password rotations"
}

variable "alarm_actions" {
  type        = list(string)
  description = "SNS topic ARNs for CloudWatch alarms"
}

variable "cpu_threshold" {
  type        = number
  description = "CPU utilization alarm threshold"
}

variable "memory_threshold" {
  type        = number
  description = "Free memory alarm threshold in bytes"
}

variable "storage_threshold" {
  type        = number
  description = "Free storage alarm threshold in bytes"
}

variable "connections_threshold" {
  type        = number
  description = "Database connections alarm threshold"
}

variable "latency_threshold" {
  type        = number
  description = "Read/Write latency alarm threshold in seconds"
}
