variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for RDS"
  type        = list(string)
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "engine_version" {
  description = "SQL Server engine version"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling"
  type        = number
}

variable "storage_type" {
  description = "Storage type"
  type        = string
}

variable "iops" {
  description = "IOPS for the storage"
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Storage throughput for gp3"
  type        = number
  default     = null
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "master_username" {
  description = "Master username"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "license_model" {
  description = "License model"
  type        = string
}

variable "timezone" {
  description = "SQL Server timezone"
  type        = string
}

variable "character_set_name" {
  description = "Character set name"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
}

variable "backup_retention_period" {
  description = "Backup retention period"
  type        = number
}

variable "backup_window" {
  description = "Backup window"
  type        = string
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot"
  type        = bool
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshot"
  type        = bool
}

variable "enabled_cloudwatch_logs_exports" {
  description = "CloudWatch logs to export"
  type        = list(string)
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention"
  type        = number
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval"
  type        = number
}

variable "monitoring_role_arn" {
  description = "Monitoring role ARN"
  type        = string
}

variable "publicly_accessible" {
  description = "Publicly accessible"
  type        = bool
}

variable "deletion_protection" {
  description = "Deletion protection"
  type        = bool
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Allowed security group IDs"
  type        = list(string)
  default     = []
}

variable "auto_minor_version_upgrade" {
  description = "Auto minor version upgrade"
  type        = bool
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
