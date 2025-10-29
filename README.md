
# Tap Assignment: Unified Terraform AWS RDS SQL Server

Provision SQL Server RDS on AWS with a unified, minimal Terraform setup supporting multiple environments (dev, stg, prod, and more).

## Known Issues

1. **Secrets Deletion Delay**: AWS Secrets Manager enforces a recovery window of 7–30 days before secrets are permanently deleted. Destroying an environment and immediately recreating it with the same secret name will fail unless you rename the secret or manually force deletion.
2. **Log Groups Not Destroyed**: CloudWatch log groups created for RDS do not get removed by `terraform destroy`. This is under investigation; manual cleanup may be required.
3. **IAM Roles Not Destroyed**: IAM roles created for RDS monitoring and EC2 secrets access may not be removed by `terraform destroy`. Manual cleanup may be required.

