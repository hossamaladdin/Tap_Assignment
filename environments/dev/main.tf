module "deployment" {
  source = "../../modules/deployment"

  project_name        = var.project_name
  environment         = "dev"
  aws_region          = var.aws_region
  s3_endpoint         = var.s3_endpoint
  allowed_cidr_blocks = var.allowed_cidr_blocks

  # Dev-specific RDS configuration
  instance_class             = "db.m5.large"
  multi_az                   = false
  backup_retention_period    = 3
  deletion_protection        = false
  allocated_storage          = 100
  max_allocated_storage      = 200
  storage_type               = "gp3"
  iops                       = null
  auto_minor_version_upgrade = true
  skip_final_snapshot        = true
  delete_automated_backups   = true
}
