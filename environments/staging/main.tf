module "deployment" {
  source = "../../modules/deployment"

  project_name        = var.project_name
  environment         = "staging"
  aws_region          = var.aws_region
  s3_endpoint         = var.s3_endpoint
  allowed_cidr_blocks = var.allowed_cidr_blocks

  # Staging-specific RDS configuration
  instance_class             = "db.m5.xlarge"
  multi_az                   = true
  backup_retention_period    = 7
  deletion_protection        = true
  allocated_storage          = 200
  max_allocated_storage      = 500
  storage_type               = "gp3"
  iops                       = null
  auto_minor_version_upgrade = false
  skip_final_snapshot        = false
  delete_automated_backups   = true
}
