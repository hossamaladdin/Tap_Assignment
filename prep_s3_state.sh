#!/bin/bash
set -e

BUCKET="tap-assignment-tfstate"
REGION="us-east-1"

echo "🔧 Setting up S3 backend for Terraform state..."
echo "   Bucket: $BUCKET"
echo "   Region: $REGION"
echo ""

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

echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

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

echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "Creating environment folders..."
for ENV in $(find env -mindepth 1 -maxdepth 1 -type d -printf '%f\n'); do
  if ! aws s3api list-objects-v2 --bucket "$BUCKET" --prefix "$ENV/" --delimiter '/' --query "CommonPrefixes[].Prefix" --output text | grep -q "^$ENV/$"; then
    aws s3api put-object --bucket "$BUCKET" --key "$ENV/" || true
    echo "   Created S3 folder/object for $ENV"
  else
    echo "   S3 folder/object for $ENV already exists, skipping."
  fi
done

echo ""
echo "✅ S3 bucket $BUCKET is ready for Terraform remote state!"
echo ""
echo "Next steps:"
echo "1. Navigate to an environment: cd env/dev"
echo "2. Initialize Terraform: terraform init"
echo "3. Review the plan: terraform plan"
echo "4. Apply if satisfied: terraform apply"
