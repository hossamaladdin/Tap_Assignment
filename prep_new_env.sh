#!/bin/bash
set -e
NEW_ENV="$1"
if [ -z "$NEW_ENV" ]; then echo "Usage: $0 <env-name>"; exit 1; fi
mkdir -p env/$NEW_ENV
cp env/dev/main.tf env/$NEW_ENV/main.tf
sed -i "s/environment = \"dev\"/environment = \"$NEW_ENV\"/g" env/$NEW_ENV/main.tf
sed -i "s/key    = \"dev\/terraform.tfstate\"/key    = \"$NEW_ENV\/terraform.tfstate\"/g" env/$NEW_ENV/main.tf
sed -i "s/Environment = \"dev\"/Environment = \"$NEW_ENV\"/g" env/$NEW_ENV/main.tf
echo "Created env/$NEW_ENV/main.tf for environment $NEW_ENV."
