resource "random_password" "master" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

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

resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
  description       = "Allow all outbound traffic"
}

resource "aws_db_parameter_group" "sqlserver" {
  name_prefix = "${var.name_prefix}-sqlserver-"
  family      = "sqlserver-se-15.0"
  description = "Custom parameter group for SQL Server"

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

resource "aws_db_option_group" "sqlserver" {
  name_prefix              = "${var.name_prefix}-sqlserver-"
  option_group_description = "Option group for SQL Server"
  engine_name              = "sqlserver-se"
  major_engine_version     = "15.00"

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
  kms_key_id            = var.kms_key_id
  storage_throughput    = var.storage_type == "gp3" ? var.storage_throughput : null

  db_name  = null
  username = var.master_username
  password = random_password.master.result
  port     = 1433
  timezone = var.timezone

  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  parameter_group_name = aws_db_parameter_group.sqlserver.name
  option_group_name    = aws_db_option_group.sqlserver.name

  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  delete_automated_backups  = var.delete_automated_backups
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-sqlserver-final-snapshot-${formatdate("YYYY-MM-DD-HHmm", timestamp())}"

  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

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

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password
    ]
  }
}


