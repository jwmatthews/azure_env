# Azure authentication
This file contains instructions for authenticating with Azure using the Azure CLI.

## login
* Our default means of interacting with Azure is with the az tool and logging in:
    * `az login`
* Alternative is to set these environment variables:
    * AZURE_CLIENT_ID
    * AZURE_CLIENT_SECRET
    * AZURE_TENANT_ID
    * AZURE_SUBSCRIPTION_ID
* You can find an example of how to obtain these environment variables in [../create_service_principal.sh](../create_service_principal.sh)

## Default storage locations for the `az` CLI tool
### Main credential cache directory
* ~/.azure/

### Specific files:
* ~/.azure/azureProfile.json      # Account/subscription info
* ~/.azure/accessTokens.json     # Access tokens (encrypted)
* ~/.azure/refreshTokens.json    # Refresh tokens (encrypted)
*   ~/.azure/msal_token_cache.json # MSAL token cache (newer auth)


## Show where Azure CLI stores data
az --version

## Show current login info
az account show

## List all stored accounts
az account list

## Show Azure CLI configuration
az configure --list-defaults

## Check what account you're logged in as
az account show --query '{Name:name, User:user.name, TenantId:tenantId, SubscriptionId:id}' --output table

## Check token expiration
az account get-access-token --query '{ExpiresOn:expiresOn, TokenType:tokenType}'

## List all cached accounts
az account list --query '[].{Name:name, User:user.name, State:state}' --output table

### Refresh a token
#### Force re-authentication
az logout
az login

#### Or refresh tokens
az account get-access-token --refresh
