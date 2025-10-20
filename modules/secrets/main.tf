# Generate random password if not provided
resource "random_password" "master" {
  count   = var.db_master_password == "" ? 1 : 0
  length  = 32
  special = true
  # SQL Server password requirements
  override_special = "!#$%&*()-_=+[]{}:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

# Secrets Manager secret for database credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.name_prefix}-db-credentials-"
  description             = "RDS SQL Server master credentials"
  recovery_window_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-credentials"
    }
  )
}

# Store credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_master_username
    password = var.db_master_password != "" ? var.db_master_password : random_password.master[0].result
    engine   = "sqlserver"
    host     = "" # Will be updated after RDS creation
    port     = 1433
  })

  lifecycle {
    ignore_changes = [
      secret_string # Prevent overwriting if manually updated
    ]
  }
}

# Output the actual password being used
locals {
  db_password = var.db_master_password != "" ? var.db_master_password : random_password.master[0].result
}
