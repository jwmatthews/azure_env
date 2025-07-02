#!/bin/sh
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <service-principal-name>"
  exit 1
fi

SP_NAME="$1"
SP_ID=$(az ad sp list --display-name "$SP_NAME" --query "[0].id" -o tsv)

if [ -z "$SP_ID" ]; then
  echo "❌ No service principal found with name: $SP_NAME"
  exit 1
fi

echo "✅ Deleting service principal with ID: $SP_ID"
az ad sp delete --id "$SP_ID"
