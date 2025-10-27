module "deployment" {
  source = "../../modules/deployment"

  project_name        = var.project_name
  environment         = "prod"
  aws_region          = var.aws_region
  allowed_cidr_blocks = var.allowed_cidr_blocks
  kms_key_id          = var.kms_key_id

  # Production-specific RDS configuration
  instance_class             = "db.m5.2xlarge"
  multi_az                   = true
  backup_retention_period    = 14
  deletion_protection        = true
  allocated_storage          = 500
  max_allocated_storage      = 1000
  storage_type               = "io1"
  iops                       = 2500
  auto_minor_version_upgrade = false
  skip_final_snapshot        = false
  delete_automated_backups   = false
}

