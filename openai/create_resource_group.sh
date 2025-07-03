#!/bin/sh

set -euo pipefail

# === Check Required Variables ===
required_vars=(
  RESOURCE_GROUP
  LOCATION
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Environment variable '$var' is not set"
    exit 1
  fi
done

echo "🔧 Creating resource group: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
