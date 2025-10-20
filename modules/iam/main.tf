# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "${var.name_prefix}-rds-monitoring-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-monitoring-role"
    }
  )
}

# Attach AWS managed policy for RDS Enhanced Monitoring
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# IAM Role for EC2 instances to access Secrets Manager
resource "aws_iam_role" "ec2_secrets_access" {
  name_prefix = "${var.name_prefix}-ec2-secrets-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ec2-secrets-role"
    }
  )
}

# IAM Policy for Secrets Manager access
resource "aws_iam_policy" "secrets_access" {
  name_prefix = "${var.name_prefix}-secrets-access-"
  description = "Policy for accessing RDS credentials in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.name_prefix}-db-credentials-*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.*.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach Secrets Manager policy to EC2 role
resource "aws_iam_role_policy_attachment" "ec2_secrets_access" {
  role       = aws_iam_role.ec2_secrets_access.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_secrets_access" {
  name_prefix = "${var.name_prefix}-ec2-secrets-"
  role        = aws_iam_role.ec2_secrets_access.name

  tags = var.tags
}
