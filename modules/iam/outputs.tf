output "rds_monitoring_role_arn" {
  value = aws_iam_role.rds_monitoring.arn
}

output "rds_monitoring_role_name" {
  value = aws_iam_role.rds_monitoring.name
}

output "ec2_secrets_role_arn" {
  value = aws_iam_role.ec2_secrets_access.arn
}

output "ec2_secrets_role_name" {
  value = aws_iam_role.ec2_secrets_access.name
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_secrets_access.name
}

output "ec2_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_secrets_access.arn
}

output "secrets_access_policy_arn" {
  value = aws_iam_policy.secrets_access.arn
}
