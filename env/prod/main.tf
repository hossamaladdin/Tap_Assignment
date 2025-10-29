variable "s3_bucket" {
  type    = string
  default = "tap-assignment-tfstate"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = var.s3_bucket
    key    = "prod/terraform.tfstate"
    region = var.aws_region
  }
}



source       = "../../modules/deployment"
project_name = "sql-rds"
environment  = "prod"
