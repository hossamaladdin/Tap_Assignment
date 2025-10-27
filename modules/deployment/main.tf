locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "../vpc"

  name_prefix        = local.name_prefix
  s3_endpoint        = var.s3_endpoint
  enable_s3_endpoint = var.enable_s3_endpoint
  tags               = local.common_tags
}

module "iam" {
  source = "../iam"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "rds" {
  source     = "../rds"
  depends_on = [module.vpc, module.iam]

  name_prefix         = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  monitoring_role_arn = module.iam.rds_monitoring_role_arn
  allowed_cidr_blocks = var.allowed_cidr_blocks
  kms_key_id          = var.kms_key_id

  instance_class             = var.instance_class
  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_period
  deletion_protection        = var.deletion_protection
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = var.max_allocated_storage
  storage_type               = var.storage_type
  iops                       = var.iops
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  skip_final_snapshot        = var.skip_final_snapshot
  delete_automated_backups   = var.delete_automated_backups

  tags = local.common_tags
}
