#!/bin/bash
# Simple script to update RDS endpoint in Secrets Manager
# Usage: ./update_secret.sh <secret-name> <rds-endpoint>

SECRET_NAME=$1
RDS_ENDPOINT=$2

if [ -z "$SECRET_NAME" ] || [ -z "$RDS_ENDPOINT" ]; then
    echo "Usage: $0 <secret-name> <rds-endpoint>"
    exit 1
fi

# Get current secret and update endpoint
CURRENT_SECRET=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)
UPDATED_SECRET=$(echo $CURRENT_SECRET | jq --arg endpoint "$RDS_ENDPOINT" '.host = $endpoint')

# Update the secret
aws secretsmanager update-secret --secret-id "$SECRET_NAME" --secret-string "$UPDATED_SECRET"
echo "Updated secret with RDS endpoint: $RDS_ENDPOINT"
