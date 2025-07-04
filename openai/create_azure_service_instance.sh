#!/bin/sh
#
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

#Creates an Azure OpenAI Service Instance
echo "🧠 Creating Azure OpenAI resource: $OPENAI_RESOURCE_NAME"
az cognitiveservices account create \
  --name "$OPENAI_RESOURCE_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --kind OpenAI \
  --sku S0 \
  --location "$LOCATION" \
  --yes \
  --custom-domain "$OPENAI_RESOURCE_NAME"
