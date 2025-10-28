module "deployment" {
  source = "./modules/deployment"

  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region
  s3_endpoint         = "com.amazonaws.${var.aws_region}.s3"
  allowed_cidr_blocks = var.allowed_cidr_blocks
  single_nat_gateway  = var.single_nat_gateway

  instance_class             = "db.m5.large"
  multi_az                   = true
  backup_retention_period    = 7
  deletion_protection        = true
  allocated_storage          = 100
  max_allocated_storage      = 200
  storage_type               = "gp3"
  iops                       = 3000
  auto_minor_version_upgrade = true
  skip_final_snapshot        = false
  delete_automated_backups   = false
}
