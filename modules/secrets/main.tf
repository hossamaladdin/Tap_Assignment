resource "random_password" "master" {
  count            = var.db_master_password == "" ? 1 : 0
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.name_prefix}-db-credentials"
  description             = "RDS SQL Server master credentials"
  recovery_window_in_days = 7
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-db-credentials" })
}

resource "aws_secretsmanager_secret_rotation" "db_credentials" {
  count               = var.enable_rotation ? 1 : 0
  secret_id           = aws_secretsmanager_secret.db_credentials.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_master_username
    password = var.db_master_password != "" ? var.db_master_password : random_password.master[0].result
    engine   = "sqlserver"
    host     = ""
    port     = 1433
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

locals {
  db_password = var.db_master_password != "" ? var.db_master_password : random_password.master[0].result
}
