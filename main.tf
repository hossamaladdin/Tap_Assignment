locals {
  environment = terraform.workspace == "default" ? "dev" : terraform.workspace
  
  is_prod = contains(["prod", "production"], lower(local.environment))
  is_staging = contains(["stage", "staging", "test"], lower(local.environment))
  is_dev = !local.is_prod && !local.is_staging
  
  env_short = local.is_prod ? "prod" : (local.is_staging ? "stage" : "dev")
  name_prefix = "${var.project_name}-${local.env_short}"

  env_config = {
    instance_class = local.is_prod ? "db.m5.2xlarge" : (local.is_staging ? "db.m5.xlarge" : "db.m5.large")
    multi_az = local.is_prod || local.is_staging
    backup_retention = local.is_prod ? 14 : (local.is_staging ? 7 : 3)
    deletion_protection = local.is_prod || local.is_staging
    allocated_storage = local.is_prod ? 500 : (local.is_staging ? 200 : 100)
    max_allocated_storage = local.is_prod ? 1000 : (local.is_staging ? 500 : 200)
    storage_type = local.is_prod ? "io1" : "gp3"
    iops = local.is_prod ? 2500 : null  # Required for io1, 5 IOPS per GB (500GB * 5 = 2500)
    auto_minor_version_upgrade = local.is_dev
    skip_final_snapshot = local.is_dev
    delete_automated_backups = local.is_dev || local.is_staging
  }
  
  common_tags = {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix        = local.name_prefix
  s3_endpoint        = var.s3_endpoint
  enable_s3_endpoint = var.enable_s3_endpoint
  tags              = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "rds" {
  source = "./modules/rds"
  depends_on = [module.vpc, module.iam]

  name_prefix          = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  monitoring_role_arn = module.iam.rds_monitoring_role_arn
  
  instance_class           = local.env_config.instance_class
  multi_az                = local.env_config.multi_az
  backup_retention_period = local.env_config.backup_retention
  deletion_protection     = local.env_config.deletion_protection
  allocated_storage       = local.env_config.allocated_storage
  max_allocated_storage   = local.env_config.max_allocated_storage
  storage_type           = local.env_config.storage_type
  iops                   = local.env_config.iops
  auto_minor_version_upgrade = local.env_config.auto_minor_version_upgrade
  skip_final_snapshot     = local.env_config.skip_final_snapshot
  delete_automated_backups = local.env_config.delete_automated_backups
  
  tags = local.common_tags
}
