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

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Use a single NAT Gateway for cost optimization. Set to false for production high-availability (3 NAT Gateways)."
}
