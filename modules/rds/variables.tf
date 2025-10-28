variable "name_prefix" {
  type    = string
  default = "sql-rds"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_class" {
  type    = string
  default = "db.t3.large"
}

variable "engine_version" {
  type    = string
  default = "15.00.4335.1.v1"
}

variable "allocated_storage" {
  type    = number
  default = 100
}

variable "max_allocated_storage" {
  type    = number
  default = 200
}

variable "storage_type" {
  type    = string
  default = "gp3"
}

variable "iops" {
  type    = number
  default = null
}

variable "storage_throughput" {
  type    = number
  default = 125
}

variable "master_username" {
  type      = string
  default   = "sqladmin"
  sensitive = true
}

variable "license_model" {
  type    = string
  default = "license-included"
}

variable "timezone" {
  type    = string
  default = "UTC"
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "backup_window" {
  type    = string
  default = "03:00-04:00"
}

variable "maintenance_window" {
  type    = string
  default = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "delete_automated_backups" {
  type    = bool
  default = true
}

variable "copy_tags_to_snapshot" {
  type    = bool
  default = true
}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = true
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = ["error", "agent"]
}

variable "monitoring_interval" {
  type    = number
  default = 60
}

variable "monitoring_role_arn" {
  type    = string
  default = null
}

variable "performance_insights_enabled" {
  type    = bool
  default = true
}

variable "performance_insights_retention_period" {
  type    = number
  default = 7
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "allowed_security_group_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "master_password" {
  type      = string
  sensitive = true
}
