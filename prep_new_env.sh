#!/bin/bash
set -e

NEW_ENV="$1"

if [ -z "$NEW_ENV" ]; then
  echo "Usage: $0 <env-name>"
  echo "Example: $0 preprod"
  exit 1
fi

echo "🔧 Creating new environment: $NEW_ENV"
echo ""

# Create environment directory
mkdir -p "env/$NEW_ENV"

# Check if templates exist
if [ ! -f "main.tf.template" ]; then
  echo "❌ Error: main.tf.template not found in root directory"
  exit 1
fi

# Copy variables.tf from dev (it's the same for all environments)
if [ -f "env/dev/variables.tf" ]; then
  cp "env/dev/variables.tf" "env/$NEW_ENV/variables.tf"
  echo "✓ Copied variables.tf"
else
  echo "❌ Error: env/dev/variables.tf not found"
  exit 1
fi

# Generate main.tf from template
sed "s/ENV_NAME/$NEW_ENV/g" "main.tf.template" > "env/$NEW_ENV/main.tf"
echo "✓ Generated main.tf from template"

# Create symlink to global config
cd "env/$NEW_ENV"
ln -sf "../../config.auto.tfvars" "config.auto.tfvars"
cd ../..
echo "✓ Created symlink to config.auto.tfvars"

echo ""
echo "✅ Successfully created env/$NEW_ENV/ with:"
echo "   - main.tf (environment: $NEW_ENV)"
echo "   - variables.tf (variable declarations)"
echo "   - config.auto.tfvars (symlink to global config)"
echo ""
echo "📋 Next steps:"
echo "1. cd env/$NEW_ENV"
echo "2. terraform init"
echo "3. terraform plan"
echo "4. terraform apply"
echo ""
echo "💡 To customize settings for this environment:"
echo "   - Edit ../../config.auto.tfvars (affects all envs)"
echo "   - Or create $NEW_ENV.tfvars for environment-specific overrides"
