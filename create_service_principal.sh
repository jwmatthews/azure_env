#!/bin/sh

# Azure Service Principal Creation Script with External Configuration
# Creates a service principal with specified role for a specific subscription
# Requires: Azure CLI (az) installed and authenticated

# Exit on any error, undefined variable, or pipe failure
set -eu

OUTPUT_CREDENTIALS_FILE="my_azure_credentials.env"

# Azure Role (optional - defaults to Contributor in script)
# Common roles: Contributor, Reader, Owner, Custom roles
AZURE_ROLE="${AZURE_ROLE:-Contributor}"

# Scope (optional - defaults to subscription level in script)
# Can be subscription, resource group, or resource level
# Examples:
# - /subscriptions/${AZURE_SUBSCRIPTION_ID}
# - /subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/myResourceGroup
# - /subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/myRG/providers/Microsoft.Storage/storageAccounts/mystorageaccount
AZURE_SCOPE="${AZURE_SCOPE:-/subscriptions/${AZURE_SUBSCRIPTION_ID}}"

# Output format (optional)
# Valid values: json, jsonc, none, table, tsv, yaml, yamlc
# Default: json (sdk-auth provides json suitable for SDKs)
OUTPUT_FORMAT="${OUTPUT_FORMAT:-json}"

# Function to print error messages
error_exit() {
    printf 'Error: %s\n' "$1" >&2
    exit "${2:-1}"
}

# Function to validate required variables
validate_env() {
    local missing_vars=""

    # Check required variables
    [ -z "${AZURE_SP_NAME:-}" ] && missing_vars="${missing_vars} AZURE_SP_NAME"
    [ -z "${AZURE_SUBSCRIPTION_ID:-}" ] && missing_vars="${missing_vars} AZURE_SUBSCRIPTION_ID"

    if [ -n "${missing_vars}" ]; then
        error_exit "Missing required configuration variables:${missing_vars}" 1
    fi

    # Validate SUBSCRIPTION_ID format (basic UUID check)
    case "${AZURE_SUBSCRIPTION_ID}" in
        *[!0-9a-fA-F-]*)
            error_exit "Invalid AZURE_SUBSCRIPTION_ID format. Expected UUID format." 1
            ;;
        ????????-????-????-????-????????????)
            # Valid UUID format
            ;;
        *)
            error_exit "Invalid AZURE_SUBSCRIPTION_ID format. Expected UUID format." 1
            ;;
    esac

    # Validate NAME (basic checks)
    case "${AZURE_SP_NAME}" in
        "")
            error_exit "AZURE_SP_NAME cannot be empty" 1
            ;;
        *" "*)
            error_exit "AZURE_SP_NAME should not contain spaces" 1
            ;;
    esac
}

# Validate configuration
validate_env

# Validate prerequisites
command -v az >/dev/null 2>&1 || {
    error_exit 'Azure CLI (az) is not installed or not in PATH
Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli' 1
}

# Check if already logged in to Azure
printf 'Checking Azure authentication...\n'
if ! az account show >/dev/null 2>&1; then
    error_exit 'Not logged in to Azure. Please run: az login' 1
fi

# Validate subscription exists and is accessible
printf 'Validating subscription access...\n'
if ! az account show --subscription "${AZURE_SUBSCRIPTION_ID}" >/dev/null 2>&1; then
    error_exit "Cannot access subscription: ${AZURE_SUBSCRIPTION_ID}
Please check subscription ID and permissions" 1
fi

# Display configuration
printf '\n=== Configuration ===\n'
printf 'Service Principal Name: %s\n' "${AZURE_SP_NAME}"
printf 'Subscription ID: %s\n' "${AZURE_SUBSCRIPTION_ID}"
printf 'Role: %s\n' "${AZURE_ROLE}"
printf 'Scope: %s\n' "${AZURE_SCOPE}"
printf 'Output Format: %s\n' "${OUTPUT_FORMAT}"
printf '=====================\n\n'

echo "🔐 Creating service principal: $AZURE_SP_NAME"
SP_JSON=$(az ad sp create-for-rbac \
  --name "$AZURE_SP_NAME" \
  --role "$AZURE_ROLE" \
  --scopes "$AZURE_SCOPE" \
  --output json) || {
  echo "❌ Failed to create service principal. Check your permissions and inputs."
  exit 1
}

APP_ID=$(echo "$SP_JSON" | jq -r .appId)
CLIENT_SECRET=$(echo "$SP_JSON" | jq -r .password)
TENANT_ID=$(echo "$SP_JSON" | jq -r .tenant)

if [[ -z "$APP_ID" || -z "$CLIENT_SECRET" || -z "$TENANT_ID" ]]; then
  echo "❌ Missing required fields in service principal output."
  echo "Raw output:"
  echo "$SP_JSON"
  exit 1
fi

echo "📄 Writing credentials to $OUTPUT_CREDENTIALS_FILE"
cat > "$OUTPUT_CREDENTIALS_FILE" <<EOF
export AZURE_CLIENT_ID=$APP_ID
export AZURE_CLIENT_SECRET=$CLIENT_SECRET
export AZURE_TENANT_ID=$TENANT_ID
export AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID
EOF

echo "✅ Done. To use:"
echo "    source $OUTPUT_CREDENTIALS_FILE"
