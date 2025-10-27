variable "project_name" {
  description = "Project name"
  type        = string
  default     = "tap-sqlserver"
  validation {
    condition     = length(var.project_name) > 0 && can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must be non-empty and use lowercase letters, numbers, and hyphens only."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^([a-z]{2}-[a-z]+-\\d)$", var.aws_region))
    error_message = "aws_region must match standard AWS region format (e.g., us-east-1)."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access RDS"
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for c in var.allowed_cidr_blocks : can(regex("^(?:\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", c))])
    error_message = "Each allowed_cidr_blocks entry must be a valid IPv4 CIDR (e.g., 10.0.0.0/24)."
  }
}

variable "s3_endpoint" {
  description = "S3 endpoint URL for VPC endpoint"
  type        = string
  default     = "com.amazonaws.vpce.us-east-1.s3"
}

variable "enable_s3_endpoint" {
  description = "Enable S3 VPC endpoint"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Optional customer-managed KMS key ID/ARN for RDS storage encryption (defaults to AWS-managed if null)."
  type        = string
  default     = null
}
