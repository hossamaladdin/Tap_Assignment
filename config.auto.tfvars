# Global Configuration - Shared Across All Environments
# This file is automatically loaded by Terraform in each environment directory

# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "sql-rds"

# RDS Configuration (Demo Settings)
instance_class          = "db.t3.small"  # Cost-effective for demo
allocated_storage       = 20             # Minimum for SQL Server
max_allocated_storage   = 50             # Auto-scaling limit
storage_type            = "gp2"          # General-purpose SSD (SQL Server does not support gp3)
multi_az                = false          # Single-AZ for demo (saves cost)

# Backup Configuration (Demo Settings)
backup_retention_period    = 1           # Minimum retention for demo
skip_final_snapshot        = true        # Skip final snapshot for demo
delete_automated_backups   = true        # Clean up backups on delete

# Security Configuration (Demo - NOT for production)
deletion_protection        = false       # Allow easy cleanup for demo
auto_minor_version_upgrade = true        # Keep up to date
allowed_cidr_blocks        = ["0.0.0.0/0"] # Open access for demo

# Network Configuration
single_nat_gateway = true                # Cost optimization (single NAT)
enable_s3_endpoint = true                # Cost optimization (no NAT for S3)

# Database Configuration
db_master_username = "sqladmin"

# Secrets Management
enable_rotation = false                  # Disabled for demo
rotation_days   = 30                     # Password rotation frequency (if enabled)

# Monitoring Thresholds
cpu_threshold         = 80               # CPU utilization percentage
memory_threshold      = 1073741824       # 1GB in bytes
storage_threshold     = 5368709120       # 5GB in bytes
connections_threshold = 50               # Connection count
latency_threshold     = 0.1              # Seconds

# CloudWatch Alarms (empty for demo - add SNS topic ARN for notifications)
alarm_actions = []
