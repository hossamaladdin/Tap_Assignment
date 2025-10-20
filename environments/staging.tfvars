# Staging Environment Configuration

# General
aws_region   = "us-east-1"
environment  = "staging"
project_name = "tap-rds-sqlserver"
owner        = "database-team"
cost_center  = "engineering"

# VPC Configuration
vpc_cidr             = "10.1.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

# RDS Configuration
rds_instance_class                          = "db.m5.xlarge"
rds_engine_version                          = "15.00.4335.1.v1" # SQL Server 2019 Standard
rds_allocated_storage                       = 200
rds_max_allocated_storage                   = 500
rds_storage_type                            = "gp3"
rds_storage_throughput                      = 125
rds_backup_retention_period                 = 7
rds_backup_window                           = "03:00-04:00"
rds_maintenance_window                      = "sun:04:00-sun:05:00"
rds_multi_az                                = true # Multi-AZ for high availability
rds_publicly_accessible                     = false
rds_deletion_protection                     = true
rds_skip_final_snapshot                     = false
rds_copy_tags_to_snapshot                   = true
rds_enabled_cloudwatch_logs_exports         = ["error", "agent"]
rds_performance_insights_enabled            = true
rds_performance_insights_retention_period   = 7
rds_monitoring_interval                     = 60
rds_auto_minor_version_upgrade              = false
rds_license_model                           = "license-included"
rds_timezone                                = "UTC"
rds_character_set_name                      = "SQL_Latin1_General_CP1_CI_AS"

# Database Credentials
db_master_username = "sqladmin"
# db_master_password will be auto-generated if not provided
db_name = "master"

# Security
allowed_cidr_blocks        = [] # Add your IP ranges here
allowed_security_group_ids = []

# Bastion Configuration
enable_bastion                 = true # Enable bastion for staging
bastion_instance_type          = "t3.micro"
bastion_key_name               = "" # Add your SSH key name
bastion_allowed_cidr_blocks    = [] # Add your IP ranges for SSH access
