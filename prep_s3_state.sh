#!/bin/bash
set -e
BUCKET="tap-assignment-tfstate"
REGION="us-east-1"

# Create S3 bucket for Terraform state
aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION" || true

# Enable versioning for state safety
aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled

# Create folders for each environment (optional, S3 is flat)
for ENV in dev stg prod; do
  aws s3api put-object --bucket "$BUCKET" --key "$ENV/"
done

echo "S3 bucket $BUCKET ready for Terraform remote state."
