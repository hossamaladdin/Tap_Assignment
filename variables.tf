# General Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "tap-rds-sqlserver"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "database-team"
}

variable "cost_center" {
  description = "Cost center for billing purposes"
  type        = string
  default     = "engineering"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# RDS Configuration
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.large"
}

variable "rds_engine_version" {
  description = "SQL Server engine version"
  type        = string
  default     = "15.00.4335.1.v1" # SQL Server 2019 Standard
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 100
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 500
}

variable "rds_storage_type" {
  description = "Storage type (gp3, gp2, io1)"
  type        = string
  default     = "gp3"
}

variable "rds_iops" {
  description = "IOPS for the RDS instance (required for io1, optional for gp3)"
  type        = number
  default     = null
}

variable "rds_storage_throughput" {
  description = "Storage throughput for gp3 storage type (MiB/s)"
  type        = number
  default     = 125
}

variable "rds_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "rds_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "rds_publicly_accessible" {
  description = "Make RDS instance publicly accessible"
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "rds_copy_tags_to_snapshot" {
  description = "Copy tags to snapshots"
  type        = bool
  default     = true
}

variable "rds_enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = ["error", "agent"]
}

variable "rds_performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "rds_performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

variable "rds_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
}

variable "rds_auto_minor_version_upgrade" {
  description = "Enable auto minor version upgrade"
  type        = bool
  default     = false
}

variable "rds_license_model" {
  description = "License model (license-included or bring-your-own-license)"
  type        = string
  default     = "license-included"
}

variable "rds_timezone" {
  description = "SQL Server timezone"
  type        = string
  default     = "UTC"
}

variable "rds_character_set_name" {
  description = "SQL Server character set"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

# Database Credentials
variable "db_master_username" {
  description = "Master username for RDS"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "db_master_password" {
  description = "Master password for RDS (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "master"
}

# Security
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access RDS"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to access RDS"
  type        = list(string)
  default     = []
}

# Bastion Host Configuration
variable "enable_bastion" {
  description = "Enable bastion host for database access"
  type        = bool
  default     = false
}

variable "bastion_instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_key_name" {
  description = "SSH key pair name for bastion host"
  type        = string
  default     = ""
}

variable "bastion_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to bastion"
  type        = list(string)
  default     = []
}
