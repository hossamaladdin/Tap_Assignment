#!/bin/bash
set -e

BUCKET="tap-assignment-tfstate"
REGION="us-east-1"

echo "🔧 Setting up S3 backend for Terraform state..."
echo "   Bucket: $BUCKET"
echo "   Region: $REGION"
echo ""

# Create S3 bucket for Terraform state
# Note: us-east-1 does not support LocationConstraint parameter
if [ "$REGION" = "us-east-1" ]; then
  echo "Creating S3 bucket in us-east-1..."
  aws s3api create-bucket \
    --bucket "$BUCKET" \
    --region "$REGION" 2>/dev/null || echo "   (Bucket may already exist)"
else
  echo "Creating S3 bucket in $REGION..."
  aws s3api create-bucket \
    --bucket "$BUCKET" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null || echo "   (Bucket may already exist)"
fi

# Enable versioning for state safety
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

# Enable encryption
echo "Enabling encryption..."
aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create folders for each environment (optional, S3 is flat)
echo "Creating environment folders..."
for ENV in dev stg prod pre-prod; do
  aws s3api put-object --bucket "$BUCKET" --key "$ENV/" || true
done

echo ""
echo "✅ S3 bucket $BUCKET is ready for Terraform remote state!"
echo ""
echo "Next steps:"
echo "1. Navigate to an environment: cd env/dev"
echo "2. Initialize Terraform: terraform init"
echo "3. Review the plan: terraform plan"
echo "4. Apply if satisfied: terraform apply"
