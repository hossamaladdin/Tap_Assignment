
terraform {
  backend "s3" {
    bucket  = "tap-assignment-tfstate"
    key     = "stg/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

locals {
  name_prefix = "sql-rds-stg"
  common_tags = {
    Environment = "stg"
    Project     = "sql-rds"
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source             = "../../modules/vpc"
  name_prefix        = local.name_prefix
  s3_endpoint        = "com.amazonaws.us-east-1.s3"
  enable_s3_endpoint = true
  single_nat_gateway = false
  tags               = local.common_tags
}

module "iam" {
  source      = "../../modules/iam"
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "secrets" {
  source              = "../../modules/secrets"
  name_prefix         = local.name_prefix
  environment         = "stg"
  db_master_username  = "sqladmin"
  db_master_password  = ""
  enable_rotation     = false
  rotation_lambda_arn = ""
  rotation_days       = 30
  tags                = local.common_tags
}

module "rds" {
  source                     = "../../modules/rds"
  depends_on                 = [module.vpc, module.iam, module.secrets]
  name_prefix                = local.name_prefix
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  monitoring_role_arn        = module.iam.rds_monitoring_role_arn
  allowed_cidr_blocks        = ["0.0.0.0/0"]
  kms_key_id                 = ""
  instance_class             = "db.m5.large"
  multi_az                   = false
  backup_retention_period    = 1
  deletion_protection        = false
  allocated_storage          = 20
  max_allocated_storage      = 50
  storage_type               = "gp2"
  iops                       = null
  auto_minor_version_upgrade = true
  skip_final_snapshot        = true
  delete_automated_backups   = true
  master_username            = "sqladmin"
  master_password            = module.secrets.db_password
  tags                       = local.common_tags
}

module "monitoring" {
  source                 = "../../modules/monitoring"
  depends_on             = [module.rds]
  name_prefix            = local.name_prefix
  aws_region             = "us-east-1"
  db_instance_identifier = module.rds.db_instance_identifier
  alarm_actions          = []
  cpu_threshold          = 80
  memory_threshold       = 1073741824
  storage_threshold      = 10737418240
  connections_threshold  = 100
  latency_threshold      = 0.1
  tags                   = local.common_tags
}
