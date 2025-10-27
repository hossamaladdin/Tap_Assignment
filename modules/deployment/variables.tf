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
