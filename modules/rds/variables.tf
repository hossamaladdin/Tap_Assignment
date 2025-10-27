variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "tap-sqlserver"
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
  default     = "db.t3.large"
}

variable "engine_version" {
  description = "SQL Server engine version"
  type        = string
  default     = "15.00.4335.1.v1"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 100
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling"
  type        = number
  default     = 200
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "IOPS for the storage"
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Storage throughput for gp3"
  type        = number
  default     = 125
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "master"
}

variable "master_username" {
  description = "Master username"
  type        = string
  sensitive   = true
  default     = "sqladmin"
}

variable "master_password" {
  description = "Master password"
  type        = string
  sensitive   = true
  default     = null
}

variable "license_model" {
  description = "License model"
  type        = string
  default     = "license-included"
}

variable "timezone" {
  description = "SQL Server timezone"
  type        = string
  default     = "UTC"
}

variable "character_set_name" {
  description = "Character set name"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot"
  type        = bool
  default     = false
}

variable "delete_automated_backups" {
  description = "Delete automated backups on destroy"
  type        = bool
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshot"
  type        = bool
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  description = "CloudWatch logs to export"
  type        = list(string)
  default     = ["error", "agent"]
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention"
  type        = number
  default     = 7
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval"
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "Monitoring role ARN"
  type        = string
  default     = null
}

variable "publicly_accessible" {
  description = "Publicly accessible"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Deletion protection"
  type        = bool
  default     = true
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
