variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for bastion host"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to bastion"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "RDS security group ID to allow access from bastion"
  type        = string
}

variable "secret_arn" {
  description = "Secrets Manager secret ARN for database credentials"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
