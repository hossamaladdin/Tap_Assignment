#!/bin/bash
#
# Script to update RDS endpoint in Secrets Manager after RDS creation
# Usage: ./update_secret.sh <secret-name> <rds-endpoint>
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is not installed. Please install it first."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Parse arguments
SECRET_NAME=$1
RDS_ENDPOINT=$2

if [ -z "$SECRET_NAME" ] || [ -z "$RDS_ENDPOINT" ]; then
    print_error "Usage: $0 <secret-name> <rds-endpoint>"
    print_info "Example: $0 tap-rds-sqlserver-dev-db-credentials-xxxxx mydb.cluster-abc123.us-east-1.rds.amazonaws.com"
    exit 1
fi

# Get AWS region
AWS_REGION=${AWS_REGION:-$(aws configure get region)}
if [ -z "$AWS_REGION" ]; then
    print_error "AWS region not set. Please set AWS_REGION environment variable or configure AWS CLI."
    exit 1
fi

print_info "AWS Region: $AWS_REGION"
print_info "Secret Name: $SECRET_NAME"
print_info "RDS Endpoint: $RDS_ENDPOINT"

# Retrieve current secret
print_info "Retrieving current secret value..."
CURRENT_SECRET=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --region $AWS_REGION \
    --query SecretString \
    --output text)

if [ -z "$CURRENT_SECRET" ]; then
    print_error "Failed to retrieve secret from Secrets Manager."
    exit 1
fi

# Update the host field
print_info "Updating RDS endpoint in secret..."
UPDATED_SECRET=$(echo $CURRENT_SECRET | jq --arg endpoint "$RDS_ENDPOINT" '.host = $endpoint')

# Update the secret
aws secretsmanager update-secret \
    --secret-id "$SECRET_NAME" \
    --region $AWS_REGION \
    --secret-string "$UPDATED_SECRET"

print_info "Successfully updated secret with RDS endpoint!"

# Verify the update
print_info "Verifying update..."
VERIFIED_SECRET=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --region $AWS_REGION \
    --query SecretString \
    --output text)

VERIFIED_HOST=$(echo $VERIFIED_SECRET | jq -r .host)

if [ "$VERIFIED_HOST" == "$RDS_ENDPOINT" ]; then
    print_info "Verification successful! RDS endpoint is set to: $VERIFIED_HOST"
else
    print_error "Verification failed. Expected: $RDS_ENDPOINT, Got: $VERIFIED_HOST"
    exit 1
fi
