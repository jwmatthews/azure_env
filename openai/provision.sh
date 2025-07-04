#!/bin/sh

set -euo pipefail

# === Check Required Variables ===
required_vars=(
  RESOURCE_GROUP
  LOCATION
  OPENAI_RESOURCE_NAME
  DEPLOYMENT_NAME
  MODEL_NAME
  MODEL_VERSION
  API_VERSION
  MODEL_CREDENTIALS
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Environment variable '$var' is not set"
    exit 1
  fi
done


./create_resource_group.sh
./create_azure_service_instance.sh
./deploy_model.sh
./write_credentials_for_openai.sh
