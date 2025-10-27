module "deployment" {
  source = "./modules/deployment"

  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region
  s3_endpoint         = "https://s3.${var.aws_region}.amazonaws.com"
  allowed_cidr_blocks = var.allowed_cidr_blocks

  instance_class             = "db.m5.large"
  multi_az                   = true
  backup_retention_period    = 7
  deletion_protection        = false
  allocated_storage          = 100
  max_allocated_storage      = 200
  storage_type               = "gp3"
  iops                       = null
  auto_minor_version_upgrade = true
  skip_final_snapshot        = false
  delete_automated_backups   = false
}
