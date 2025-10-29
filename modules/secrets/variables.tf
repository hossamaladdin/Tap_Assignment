variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type = string
}

variable "name_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "db_master_username" {
  type = string
}

variable "db_master_password" {
  type    = string
  default = ""
}

variable "enable_rotation" {
  type        = bool
  default     = false
  description = "Enable automatic password rotation for RDS credentials"
}

variable "rotation_lambda_arn" {
  type        = string
  default     = ""
  description = "ARN of the Lambda function for rotating RDS credentials. Required if enable_rotation is true."
}

variable "rotation_days" {
  type        = number
  default     = 30
  description = "Number of days between automatic password rotations"
}
