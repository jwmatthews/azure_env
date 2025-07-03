#!/bin/sh

set -euo pipefail

# === Check Required Variables ===
required_vars=(
  RESOURCE_GROUP
  OPENAI_RESOURCE_NAME
  DEPLOYMENT_NAME
  MODEL_NAME
  MODEL_VERSION
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Environment variable '$var' is not set"
    exit 1
  fi
done

echo "🚀 Deploying model: $MODEL_NAME"
az cognitiveservices account deployment create \
  --name "$OPENAI_RESOURCE_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --deployment-name "$DEPLOYMENT_NAME" \
  --model-name "$MODEL_NAME" \
  --model-version "$MODEL_VERSION" \
  --model-format OpenAI \
  --sku Standard \
  --capacity 1
