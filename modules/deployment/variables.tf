variable "project_name" {
  description = "Project name"
  type        = string
  default     = "tap-sqlserver"
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access RDS"
  type        = list(string)
  default     = []
}

variable "s3_endpoint" {
  description = "S3 endpoint URL for VPC endpoint"
  type        = string
  default     = "com.amazonaws.vpce-us-east-1.s3"
}

variable "enable_s3_endpoint" {
  description = "Enable S3 VPC endpoint"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Optional customer-managed KMS key ID/ARN for RDS storage encryption"
  type        = string
  default     = null
}

# RDS Configuration Variables
variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "Provisioned IOPS"
  type        = number
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "delete_automated_backups" {
  description = "Delete automated backups on instance deletion"
  type        = bool
  default     = true
}
