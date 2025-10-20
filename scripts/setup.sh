#!/bin/bash
#
# Setup script to prepare the Terraform project
# This script will guide you through the initial setup
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Clear screen
clear

print_header "AWS RDS SQL Server Infrastructure Setup"
echo ""

# Check prerequisites
print_info "Checking prerequisites..."

# Check Terraform
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform >= 1.0"
    print_info "Visit: https://www.terraform.io/downloads.html"
    exit 1
fi
TERRAFORM_VERSION=$(terraform version -json | jq -r .terraform_version)
print_info "✓ Terraform $TERRAFORM_VERSION found"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install AWS CLI >= 2.0"
    print_info "Visit: https://aws.amazon.com/cli/"
    exit 1
fi
print_info "✓ AWS CLI found"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure'"
    exit 1
fi
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
print_info "✓ AWS credentials configured (Account: $AWS_ACCOUNT)"

# Check jq
if ! command -v jq &> /dev/null; then
    print_warning "jq is not installed. It's recommended for working with JSON outputs."
    print_info "Install: https://stedolan.github.io/jq/"
fi

echo ""
print_header "Environment Selection"
echo ""
echo "1) Development (dev)"
echo "2) Staging (staging)"
echo "3) Production (prod)"
echo ""
read -p "Select environment [1-3]: " ENV_CHOICE

case $ENV_CHOICE in
    1)
        ENVIRONMENT="dev"
        ;;
    2)
        ENVIRONMENT="staging"
        ;;
    3)
        ENVIRONMENT="prod"
        ;;
    *)
        print_error "Invalid choice. Exiting."
        exit 1
        ;;
esac

print_info "Selected environment: $ENVIRONMENT"
TFVARS_FILE="environments/${ENVIRONMENT}.tfvars"

echo ""
print_header "Configuration"
echo ""

# Ask for region
read -p "AWS Region [us-east-1]: " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

# Ask for project name
read -p "Project name [tap-rds-sqlserver]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-tap-rds-sqlserver}

# Ask if bastion is needed
read -p "Enable bastion host for database access? [y/N]: " ENABLE_BASTION
if [[ $ENABLE_BASTION =~ ^[Yy]$ ]]; then
    BASTION_ENABLED=true
    read -p "SSH key name (leave empty to use SSM Session Manager): " SSH_KEY_NAME
else
    BASTION_ENABLED=false
    SSH_KEY_NAME=""
fi

echo ""
print_header "Creating Configuration"
echo ""

# Copy tfvars file
if [ -f "$TFVARS_FILE" ]; then
    print_info "Using existing $TFVARS_FILE"
else
    print_error "$TFVARS_FILE not found"
    exit 1
fi

# Initialize Terraform
print_info "Initializing Terraform..."
terraform init

echo ""
print_header "Setup Complete!"
echo ""
print_info "Next steps:"
echo ""
echo "1. Review and customize your configuration:"
echo "   vim $TFVARS_FILE"
echo ""
echo "2. Plan your deployment:"
echo "   terraform plan -var-file=$TFVARS_FILE"
echo ""
echo "3. Apply your infrastructure:"
echo "   terraform apply -var-file=$TFVARS_FILE"
echo ""
echo "4. After deployment, retrieve outputs:"
echo "   terraform output"
echo ""
print_info "For more information, see README.md"
echo ""
