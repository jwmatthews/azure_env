#!/bin/sh

set -euo pipefail

# === Check Required Variables ===
required_vars=(
  OPENAI_RESOURCE_NAME
  RESOURCE_GROUP
  LOCATION
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Environment variable '$var' is not set"
    exit 1
  fi
done

az cognitiveservices account delete \
  --name "$OPENAI_RESOURCE_NAME" \
  --resource-group "$RESOURCE_GROUP"

az cognitiveservices account purge \
  --name "$OPENAI_RESOURCE_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION"
