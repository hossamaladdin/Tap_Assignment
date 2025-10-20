#!/bin/bash
# Simple script to connect to RDS SQL Server using Secrets Manager
# Usage: ./connect_to_rds.sh <rds-endpoint> [secret-name]

RDS_ENDPOINT=$1
SECRET_NAME=$2

if [ -z "$RDS_ENDPOINT" ]; then
    echo "Usage: $0 <rds-endpoint> [secret-name]"
    exit 1
fi

# Find secret if not provided
if [ -z "$SECRET_NAME" ]; then
    SECRET_NAME=$(aws secretsmanager list-secrets --query "SecretList[?contains(Name, 'db-credentials')].Name | [0]" --output text)
fi

# Get credentials
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)
DB_USERNAME=$(echo $SECRET_JSON | jq -r .username)
DB_PASSWORD=$(echo $SECRET_JSON | jq -r .password)

# Connect to SQL Server
echo "Connecting to $RDS_ENDPOINT as $DB_USERNAME..."
sqlcmd -S "$RDS_ENDPOINT" -U "$DB_USERNAME" -P "$DB_PASSWORD" -C
