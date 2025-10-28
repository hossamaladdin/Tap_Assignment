variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "project_name" {
  type    = string
  default = "sql-rds"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
