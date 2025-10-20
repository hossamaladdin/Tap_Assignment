output "rds_monitoring_role_arn" {
  description = "ARN of the RDS monitoring role"
  value       = aws_iam_role.rds_monitoring.arn
}

output "rds_monitoring_role_name" {
  description = "Name of the RDS monitoring role"
  value       = aws_iam_role.rds_monitoring.name
}

output "ec2_secrets_role_arn" {
  description = "ARN of the EC2 secrets access role"
  value       = aws_iam_role.ec2_secrets_access.arn
}

output "ec2_secrets_role_name" {
  description = "Name of the EC2 secrets access role"
  value       = aws_iam_role.ec2_secrets_access.name
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_secrets_access.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_secrets_access.arn
}

output "secrets_access_policy_arn" {
  description = "ARN of the secrets access policy"
  value       = aws_iam_policy.secrets_access.arn
}
