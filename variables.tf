variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = length(var.environment) > 0 && length(var.environment) <= 20
    error_message = "Environment name must be between 1 and 20 characters"
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "tap-sqlserver"
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
