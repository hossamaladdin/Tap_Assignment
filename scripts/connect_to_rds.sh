#!/bin/bash
#
# Script to connect to RDS SQL Server using credentials from AWS Secrets Manager
# Usage: ./connect_to_rds.sh <rds-endpoint> [secret-name]
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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is not installed. Please install it first."
    print_info "On macOS: brew install jq"
    print_info "On Ubuntu: sudo apt-get install jq"
    print_info "On RHEL/CentOS: sudo yum install jq"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if sqlcmd is installed
if ! command -v sqlcmd &> /dev/null; then
    print_warning "sqlcmd is not installed. Install SQL Server command-line tools:"
    print_info "https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility"
    exit 1
fi

# Parse arguments
RDS_ENDPOINT=$1
SECRET_NAME=$2

if [ -z "$RDS_ENDPOINT" ]; then
    print_error "Usage: $0 <rds-endpoint> [secret-name]"
    print_info "Example: $0 mydb.cluster-abc123.us-east-1.rds.amazonaws.com"
    exit 1
fi

# Get AWS region
AWS_REGION=${AWS_REGION:-$(aws configure get region)}
if [ -z "$AWS_REGION" ]; then
    print_error "AWS region not set. Please set AWS_REGION environment variable or configure AWS CLI."
    exit 1
fi

print_info "AWS Region: $AWS_REGION"

# If secret name not provided, try to find it
if [ -z "$SECRET_NAME" ]; then
    print_info "Searching for RDS credentials secret..."
    SECRET_NAME=$(aws secretsmanager list-secrets \
        --region $AWS_REGION \
        --query "SecretList[?contains(Name, 'db-credentials')].Name | [0]" \
        --output text)
    
    if [ -z "$SECRET_NAME" ] || [ "$SECRET_NAME" == "None" ]; then
        print_error "Could not find secrets. Please provide secret name as second argument."
        exit 1
    fi
    print_info "Found secret: $SECRET_NAME"
fi

# Retrieve credentials from Secrets Manager
print_info "Retrieving database credentials from Secrets Manager..."
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --region $AWS_REGION \
    --query SecretString \
    --output text)

if [ -z "$SECRET_JSON" ]; then
    print_error "Failed to retrieve secret from Secrets Manager."
    exit 1
fi

# Parse credentials
DB_USERNAME=$(echo $SECRET_JSON | jq -r .username)
DB_PASSWORD=$(echo $SECRET_JSON | jq -r .password)

if [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
    print_error "Failed to parse credentials from secret."
    exit 1
fi

print_info "Successfully retrieved credentials"
print_info "Username: $DB_USERNAME"
print_info "Connecting to SQL Server at $RDS_ENDPOINT..."
echo ""

# Connect using sqlcmd
# -S: Server
# -U: Username
# -P: Password
# -C: Trust server certificate (required for TLS)
sqlcmd -S "$RDS_ENDPOINT" -U "$DB_USERNAME" -P "$DB_PASSWORD" -C

print_info "Connection closed."
