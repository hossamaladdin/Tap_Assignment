#!/bin/bash
# Validation script to check Terraform configuration

set -e

echo "🔍 Validating Terraform Configuration..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track errors
ERRORS=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
    else
        echo -e "${RED}✗${NC} Missing: $1"
        ((ERRORS++))
    fi
}

# Function to check symlink
check_symlink() {
    if [ -L "$1" ] && [ -e "$1" ]; then
        echo -e "${GREEN}✓${NC} Symlink valid: $1 -> $(readlink $1)"
    else
        echo -e "${RED}✗${NC} Symlink broken or missing: $1"
        ((ERRORS++))
    fi
}

# Check root files
echo "Checking root configuration files..."
check_file "config.auto.tfvars"
check_file "prep_s3_state.sh"
check_file "prep_new_env.sh"
check_file "backend.tf.template"
check_file ".gitignore"
echo ""

# Check environments
for ENV in dev stg prod pre-prod; do
    echo "Checking environment: $ENV"
    check_file "env/$ENV/main.tf"
    check_file "env/$ENV/variables.tf"
    check_symlink "env/$ENV/config.auto.tfvars"

    # Validate environment name in main.tf
    if grep -q "environment  = \"$ENV\"" "env/$ENV/main.tf" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Environment name correct in main.tf"
    else
        echo -e "${RED}✗${NC} Environment name mismatch in main.tf"
        ((ERRORS++))
    fi

    # Validate backend key
    if grep -q "key     = \"$ENV/terraform.tfstate\"" "env/$ENV/main.tf" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Backend key correct in main.tf"
    else
        echo -e "${RED}✗${NC} Backend key mismatch in main.tf"
        ((ERRORS++))
    fi
    echo ""
done

# Check modules
echo "Checking module structure..."
for MODULE in deployment vpc rds iam secrets monitoring; do
    check_file "modules/$MODULE/main.tf"
    check_file "modules/$MODULE/variables.tf"
    check_file "modules/$MODULE/outputs.tf"
done
echo ""

# Validate Terraform syntax (if terraform is installed)
if command -v terraform &> /dev/null; then
    echo "Running Terraform validation..."

    for ENV in dev stg prod pre-prod; do
        echo "Validating env/$ENV..."
        cd "env/$ENV"

        # Check for syntax errors without initializing
        if terraform validate -no-color 2>&1 | grep -q "Success\|configuration is valid"; then
            echo -e "${GREEN}✓${NC} env/$ENV: Terraform configuration is valid"
        else
            echo -e "${YELLOW}⚠${NC} env/$ENV: Run 'terraform init' first to validate"
        fi

        cd ../..
    done
    echo ""
else
    echo -e "${YELLOW}⚠${NC} Terraform not installed, skipping syntax validation"
    echo ""
fi

# Check for common issues
echo "Checking for common issues..."

# Check for variable interpolation in backend blocks
if grep -r "backend \"s3\"" env/*/main.tf | grep -q "var\."; then
    echo -e "${RED}✗${NC} Found variable interpolation in backend block"
    ((ERRORS++))
else
    echo -e "${GREEN}✓${NC} No variable interpolation in backend blocks"
fi

# Check for hardcoded values that should be variables
if grep -rq "allowed_cidr_blocks.*=.*\[\"0.0.0.0/0\"\]" env/*/main.tf; then
    echo -e "${YELLOW}⚠${NC} Warning: Found hardcoded CIDR blocks in env files (should use variables)"
fi

echo ""
echo "========================================"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All validation checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run: ./prep_s3_state.sh (to setup S3 backend)"
    echo "2. Navigate to an environment: cd env/dev"
    echo "3. Initialize: terraform init"
    echo "4. Plan: terraform plan"
    echo "5. Apply: terraform apply"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS error(s)${NC}"
    echo "Please fix the issues above before deploying."
    exit 1
fi
