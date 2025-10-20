#!/bin/bash
# Simple setup script for Terraform project

echo "AWS RDS SQL Server Infrastructure Setup"
echo "======================================="

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

echo ""
echo "Setup complete! Next steps:"
echo "1. Choose environment: terraform plan -var-file=environments/dev.tfvars"
echo "2. Deploy: terraform apply -var-file=environments/dev.tfvars"
echo "3. Get outputs: terraform output"
