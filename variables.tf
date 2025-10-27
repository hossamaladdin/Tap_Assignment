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
