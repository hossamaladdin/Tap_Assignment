variable "project_name" {
  type    = string
  default = "tap-sqlserver"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "s3_endpoint" {
  type    = string
  default = "com.amazonaws.us-east-1.s3"
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "environment" {
  type    = string
  default = "dev"
}
