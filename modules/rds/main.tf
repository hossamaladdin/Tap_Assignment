# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.name_prefix}-rds-"
  description = "Security group for RDS SQL Server"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group Rules - Ingress from CIDR blocks
resource "aws_security_group_rule" "rds_ingress_cidr" {
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 1433
  to_port           = 1433
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.rds.id
  description       = "Allow SQL Server access from specified CIDR blocks"
}

# Security Group Rules - Ingress from Security Groups
resource "aws_security_group_rule" "rds_ingress_sg" {
  count                    = length(var.allowed_security_group_ids)
  type                     = "ingress"
  from_port                = 1433
  to_port                  = 1433
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.rds.id
  description              = "Allow SQL Server access from security group ${count.index}"
}

# Security Group Rules - Egress (allow all outbound)
resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
  description       = "Allow all outbound traffic"
}

# RDS Parameter Group for SQL Server
resource "aws_db_parameter_group" "sqlserver" {
  name_prefix = "${var.name_prefix}-sqlserver-"
  family      = "sqlserver-se-15.0"
  description = "Custom parameter group for SQL Server"

  # Example parameters - customize based on your needs
  parameter {
    name  = "contained database authentication"
    value = "1"
  }

  parameter {
    name  = "cost threshold for parallelism"
    value = "50"
  }

  parameter {
    name  = "max degree of parallelism"
    value = "4"
  }

  parameter {
    name  = "optimize for ad hoc workloads"
    value = "1"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sqlserver-parameter-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Option Group for SQL Server
resource "aws_db_option_group" "sqlserver" {
  name_prefix              = "${var.name_prefix}-sqlserver-"
  option_group_description = "Option group for SQL Server"
  engine_name              = "sqlserver-se"
  major_engine_version     = "15.00"

  # Example: Enable SQL Server Audit
  # option {
  #   option_name = "SQLSERVER_AUDIT"
  #   option_settings {
  #     name  = "IAM_ROLE_ARN"
  #     value = aws_iam_role.rds_audit.arn
  #   }
  #   option_settings {
  #     name  = "S3_BUCKET_ARN"
  #     value = aws_s3_bucket.rds_audit.arn
  #   }
  # }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sqlserver-option-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Instance
resource "aws_db_instance" "sqlserver" {
  identifier = "${var.name_prefix}-sqlserver"

  # Engine
  engine         = "sqlserver-se"
  engine_version = var.engine_version
  license_model  = var.license_model

  # Instance
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  iops                  = var.iops
  storage_throughput    = var.storage_throughput

  # Database
  db_name  = null # SQL Server doesn't support db_name parameter
  username = var.master_username
  password = var.master_password
  port     = 1433
  timezone = var.timezone

  # High Availability
  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.sqlserver.name
  option_group_name    = aws_db_option_group.sqlserver.name

  # Backup
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  copy_tags_to_snapshot   = var.copy_tags_to_snapshot
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-sqlserver-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Maintenance
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Monitoring
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? var.monitoring_role_arn : null
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # Protection
  deletion_protection = var.deletion_protection

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-sqlserver"
    }
  )

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password
    ]
  }
}


