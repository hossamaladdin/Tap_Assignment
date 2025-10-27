variable "project_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "kms_key_id" {
  type    = string
  default = ""
}
