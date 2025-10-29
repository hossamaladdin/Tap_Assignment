terraform {
  backend "s3" {
    bucket  = "tap-assignment-tfstate"
    key     = "prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

module "deployment" {
  source      = "../../modules/deployment"
  environment = "prod"
}
