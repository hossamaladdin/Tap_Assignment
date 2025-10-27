output "db_password" {
  value     = local.db_password
  sensitive = true
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

output "secret_version_arn" {
  value = aws_secretsmanager_secret_version.db_credentials.arn
}
