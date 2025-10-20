# Local variables for resource naming and tagging
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  enable_nat_gateway   = var.enable_bastion
  tags                 = local.common_tags
}

# Secrets Manager Module
module "secrets" {
  source = "./modules/secrets"

  name_prefix        = local.name_prefix
  db_master_username = var.db_master_username
  db_master_password = var.db_master_password
  tags               = local.common_tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  name_prefix                             = local.name_prefix
  vpc_id                                  = module.vpc.vpc_id
  subnet_ids                              = module.vpc.private_subnet_ids
  
  # Instance Configuration
  instance_class                          = var.rds_instance_class
  engine_version                          = var.rds_engine_version
  allocated_storage                       = var.rds_allocated_storage
  max_allocated_storage                   = var.rds_max_allocated_storage
  storage_type                            = var.rds_storage_type
  iops                                    = var.rds_iops
  storage_throughput                      = var.rds_storage_throughput
  
  # Database Configuration
  db_name                                 = var.db_name
  master_username                         = var.db_master_username
  master_password                         = module.secrets.db_password
  license_model                           = var.rds_license_model
  timezone                                = var.rds_timezone
  character_set_name                      = var.rds_character_set_name
  
  # High Availability
  multi_az                                = var.rds_multi_az
  
  # Backup Configuration
  backup_retention_period                 = var.rds_backup_retention_period
  backup_window                           = var.rds_backup_window
  maintenance_window                      = var.rds_maintenance_window
  skip_final_snapshot                     = var.rds_skip_final_snapshot
  copy_tags_to_snapshot                   = var.rds_copy_tags_to_snapshot
  
  # Monitoring
  enabled_cloudwatch_logs_exports         = var.rds_enabled_cloudwatch_logs_exports
  performance_insights_enabled            = var.rds_performance_insights_enabled
  performance_insights_retention_period   = var.rds_performance_insights_retention_period
  monitoring_interval                     = var.rds_monitoring_interval
  monitoring_role_arn                     = module.iam.rds_monitoring_role_arn
  
  # Security
  publicly_accessible                     = var.rds_publicly_accessible
  deletion_protection                     = var.rds_deletion_protection
  allowed_cidr_blocks                     = var.allowed_cidr_blocks
  allowed_security_group_ids              = var.enable_bastion ? concat(var.allowed_security_group_ids, [module.bastion[0].security_group_id]) : var.allowed_security_group_ids
  
  # Updates
  auto_minor_version_upgrade              = var.rds_auto_minor_version_upgrade
  
  tags = local.common_tags
}

# Bastion Host Module (Optional)
module "bastion" {
  count  = var.enable_bastion ? 1 : 0
  source = "./modules/bastion"

  name_prefix              = local.name_prefix
  vpc_id                   = module.vpc.vpc_id
  subnet_id                = module.vpc.public_subnet_ids[0]
  instance_type            = var.bastion_instance_type
  key_name                 = var.bastion_key_name
  allowed_cidr_blocks      = var.bastion_allowed_cidr_blocks
  rds_security_group_id    = module.rds.security_group_id
  secret_arn               = module.secrets.secret_arn
  tags                     = local.common_tags
}
