#!/bin/bash

set -euo pipefail

# === Check Required Variables ===
required_vars=(
  RESOURCE_GROUP
  OPENAI_RESOURCE_NAME
  DEPLOYMENT_NAME
  API_VERSION
  MODEL_CREDENTIALS
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Environment variable '$var' is not set"
    exit 1
  fi
done


echo "🔐 Fetching endpoint and key"
ENDPOINT=$(az cognitiveservices account show \
  --name "$OPENAI_RESOURCE_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "properties.endpoint" -o tsv)

API_KEY=$(az cognitiveservices account keys list \
  --name "$OPENAI_RESOURCE_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "key1" -o tsv)

echo "📄 Writing credentials to $MODEL_CREDENTIALS"
cat > "$MODEL_CREDENTIALS" <<EOF
export AZURE_OPENAI_ENDPOINT=$ENDPOINT
export AZURE_OPENAI_DEPLOYMENT=$DEPLOYMENT_NAME
export AZURE_OPENAI_API_VERSION=$API_VERSION
export AZURE_OPENAI_API_KEY=$API_KEY
EOF
