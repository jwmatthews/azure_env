#!/bin/sh

set -euo pipefail

# === Check Required Variables ===
required_vars=(
  OPENAI_RESOURCE_NAME
  RESOURCE_GROUP
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Environment variable '$var' is not set"
    exit 1
  fi
done

az cognitiveservices account list-models \
  --name "$OPENAI_RESOURCE_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  -o table
