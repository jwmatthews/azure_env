#!/bin/sh

# Azure Service Principal Creation Script with External Configuration
# Creates a service principal with specified role for a specific subscription
# Requires: Azure CLI (az) installed and authenticated
# Configuration: Sources azure-config.sh for settings

# Exit on any error, undefined variable, or pipe failure
set -eu

# Configuration file path (relative to script location)
CONFIG_FILE="./source_me.env"

# Function to print error messages
error_exit() {
    printf 'Error: %s\n' "$1" >&2
    exit "${2:-1}"
}

# Function to validate required variables
validate_config() {
    local missing_vars=""

    # Check required variables
    [ -z "${NAME:-}" ] && missing_vars="${missing_vars} NAME"
    [ -z "${SUBSCRIPTION_ID:-}" ] && missing_vars="${missing_vars} SUBSCRIPTION_ID"

    if [ -n "${missing_vars}" ]; then
        error_exit "Missing required configuration variables:${missing_vars}
Please check your configuration file: ${CONFIG_FILE}" 1
    fi

    # Validate SUBSCRIPTION_ID format (basic UUID check)
    case "${SUBSCRIPTION_ID}" in
        *[!0-9a-fA-F-]*)
            error_exit "Invalid SUBSCRIPTION_ID format. Expected UUID format." 1
            ;;
        ????????-????-????-????-????????????)
            # Valid UUID format
            ;;
        *)
            error_exit "Invalid SUBSCRIPTION_ID format. Expected UUID format." 1
            ;;
    esac

    # Validate NAME (basic checks)
    case "${NAME}" in
        "")
            error_exit "NAME cannot be empty" 1
            ;;
        *" "*)
            error_exit "NAME should not contain spaces" 1
            ;;
    esac
}

# Check if configuration file exists
if [ ! -f "${CONFIG_FILE}" ]; then
    error_exit "Configuration file not found: ${CONFIG_FILE}
Please create the configuration file with required variables:
- NAME: Service principal name
- SUBSCRIPTION_ID: Azure subscription ID" 1
fi

# Source configuration file
printf 'Loading configuration from: %s\n' "${CONFIG_FILE}"
# shellcheck disable=SC1090
. "${CONFIG_FILE}" || error_exit "Failed to source configuration file: ${CONFIG_FILE}" 1

# Set defaults for optional variables
AZURE_ROLE="${AZURE_ROLE:-Contributor}"
AZURE_SCOPE="${AZURE_SCOPE:-/subscriptions/${SUBSCRIPTION_ID}}"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-json}"

# Validate configuration
validate_config

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
if ! az account show --subscription "${SUBSCRIPTION_ID}" >/dev/null 2>&1; then
    error_exit "Cannot access subscription: ${SUBSCRIPTION_ID}
Please check subscription ID and permissions" 1
fi

# Export variables for potential use by subprocesses
export NAME SUBSCRIPTION_ID AZURE_ROLE AZURE_SCOPE OUTPUT_FORMAT

# Display configuration
printf '\n=== Configuration ===\n'
printf 'Service Principal Name: %s\n' "${NAME}"
printf 'Subscription ID: %s\n' "${SUBSCRIPTION_ID}"
printf 'Role: %s\n' "${AZURE_ROLE}"
printf 'Scope: %s\n' "${AZURE_SCOPE}"
printf 'Output Format: %s\n' "${OUTPUT_FORMAT}"
printf '=====================\n\n'

# Confirmation prompt
printf 'Proceed with service principal creation? [y/N]: '
read -r response
case "${response}" in
    [Yy]|[Yy][Ee][Ss])
        printf 'Proceeding...\n'
        ;;
    *)
        printf 'Operation cancelled.\n'
        exit 0
        ;;
esac

# Create service principal with error handling
printf 'Creating service principal...\n'
if az ad sp create-for-rbac \
    --name "${NAME}" \
    --role "${AZURE_ROLE}" \
    --scopes "${AZURE_SCOPE}" \
    --sdk-auth \
    --output "${OUTPUT_FORMAT}"; then
    printf '\n✓ Service principal created successfully\n'
    printf '\nIMPORTANT: Save the output above securely.\n'
    printf 'These credentials will not be shown again.\n'
else
    exit_code=$?
    error_exit "Failed to create service principal (exit code: ${exit_code})" "${exit_code}"
fi
