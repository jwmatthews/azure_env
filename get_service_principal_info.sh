#!/bin/sh
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <service-principal-name>"
  exit 1
fi

SP_NAME="$1"

az ad sp list --display-name "$SP_NAME" \
  -o table
  #--query "[].{Name:displayName, AppId:appId, ObjectId:objectId}" \
