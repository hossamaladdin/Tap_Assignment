variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "s3_endpoint" {
  type    = string
  default = "com.amazonaws.us-east-1.s3"
}

variable "enable_s3_endpoint" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "instance_class" {
  type = string
}

variable "multi_az" {
  type = bool
}

variable "backup_retention_period" {
  type = number
}

variable "deletion_protection" {
  type = bool
}

variable "allocated_storage" {
  type = number
}

variable "max_allocated_storage" {
  type = number
}

variable "storage_type" {
  type = string
}

variable "iops" {
  type    = number
  default = null
}

variable "auto_minor_version_upgrade" {
  type = bool
}

variable "skip_final_snapshot" {
  type = bool
}

variable "delete_automated_backups" {
  type = bool
}

variable "db_master_username" {
  type    = string
  default = "sqladmin"
}

variable "single_nat_gateway" {
  type        = bool
  default     = false
  description = "Use a single NAT Gateway for cost optimization (saves ~$65/month per environment)"
}

variable "enable_rotation" {
  type        = bool
  default     = false
  description = "Enable automatic password rotation"
}

variable "rotation_lambda_arn" {
  type        = string
  default     = ""
  description = "Lambda ARN for password rotation"
}

variable "rotation_days" {
  type        = number
  default     = 30
  description = "Days between password rotations"
}

variable "alarm_actions" {
  type        = list(string)
  default     = []
  description = "SNS topic ARNs for CloudWatch alarm notifications"
}

variable "cpu_threshold" {
  type        = number
  default     = 80
  description = "CPU utilization alarm threshold percentage"
}

variable "memory_threshold" {
  type        = number
  default     = 1073741824
  description = "Free memory alarm threshold in bytes (1GB)"
}

variable "storage_threshold" {
  type        = number
  default     = 10737418240
  description = "Free storage alarm threshold in bytes (10GB)"
}

variable "connections_threshold" {
  type        = number
  default     = 100
  description = "Database connections alarm threshold"
}

variable "latency_threshold" {
  type        = number
  default     = 0.1
  description = "Read/Write latency alarm threshold in seconds"
}
