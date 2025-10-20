# Local variables for resource naming and tagging
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Automatically determine environment-specific settings
  env_configs = {
    dev = {
      instance_class        = "db.t3.large"
      multi_az             = false
      backup_retention     = 3
      deletion_protection  = false
      allocated_storage    = 100
      max_allocated_storage = 200
      auto_minor_version_upgrade = true
      storage_type         = "gp3"
    }
    staging = {
      instance_class        = "db.m5.xlarge"
      multi_az             = true
      backup_retention     = 7
      deletion_protection  = true
      allocated_storage    = 200
      max_allocated_storage = 500
      auto_minor_version_upgrade = false
      storage_type         = "gp3"
    }
    prod = {
      instance_class        = "db.m5.2xlarge"
      multi_az             = true
      backup_retention     = 14
      deletion_protection  = true
      allocated_storage    = 500
      max_allocated_storage = 1000
      auto_minor_version_upgrade = false
      storage_type         = "io1"
    }
  }

  # Get environment-specific config with dev as fallback
  env_config = lookup(local.env_configs, var.environment, local.env_configs.dev)
  
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# VPC Module - Creates the networking infrastructure
module "vpc" {
  source = "./modules/vpc"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# Secrets Manager Module - Handles database credentials
module "secrets" {
  source = "./modules/secrets"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# IAM Module - Creates necessary IAM roles
module "iam" {
  source = "./modules/iam"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# RDS Module - Creates the SQL Server instance
module "rds" {
  source = "./modules/rds"
  depends_on = [module.vpc, module.secrets, module.iam]

  name_prefix          = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  master_password     = module.secrets.db_password
  monitoring_role_arn = module.iam.rds_monitoring_role_arn
  
  # Use environment-specific configurations
  instance_class           = local.env_config.instance_class
  multi_az                = local.env_config.multi_az
  backup_retention_period = local.env_config.backup_retention
  deletion_protection     = local.env_config.deletion_protection
  allocated_storage       = local.env_config.allocated_storage
  max_allocated_storage   = local.env_config.max_allocated_storage
  storage_type           = local.env_config.storage_type
  auto_minor_version_upgrade = local.env_config.auto_minor_version_upgrade
  
  tags = local.common_tags
}
