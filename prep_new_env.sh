
#!/bin/bash
set -e

NEW_ENV="$1"

if [ -z "$NEW_ENV" ]; then
  echo "Usage: $0 <env-name>"
  echo "Example: $0 dev"
  exit 1
fi

echo "🔧 Creating new environment: $NEW_ENV"

BUCKET="tap-assignment-tfstate"
if command -v aws >/dev/null 2>&1; then
  if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
    aws s3api put-object --bucket "$BUCKET" --key "$NEW_ENV/" || true
    echo "✓ S3 folder/object for $NEW_ENV created in $BUCKET"
  else
    echo "⚠️  S3 bucket $BUCKET does not exist. Run prep_s3_state.sh to set up the backend."
  fi
else
  echo "❌ Error: AWS CLI not found. Please install awscli to enable S3 state setup."
fi

mkdir -p "env/$NEW_ENV"





if [ -f "main.tf.template" ]; then
  sed "s/ENV_NAME/$NEW_ENV/g" "main.tf.template" > "env/$NEW_ENV/main.tf"
  echo "✓ Generated minimal main.tf from template"
else
  echo "❌ Error: main.tf.template not found in root directory"
  exit 1
fi



echo ""
echo "✅ Successfully created env/$NEW_ENV/ with:"
echo "   - main.tf (environment: $NEW_ENV)"
echo "   - variables.tf (only 'environment' variable)"
echo "   - config.auto.tfvars (symlink to global config, only 'environment')"
echo ""
echo "📋 Next steps:"
echo "1. cd env/$NEW_ENV"
echo "2. terraform init"
echo "3. terraform plan"
echo "4. terraform apply"
