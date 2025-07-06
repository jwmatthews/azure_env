# Azure scripts to help with provisioning
The scripts in this directory help for working with Azure APIs to provision resources.
* IMPORTANT never commit your credentials to your repository
* These scripts will create files ending in `*.env` which have credentials to access your Azure account.
* Please ensure you never commit the `*.env` files to your repository.
  * We have an entry in `.gitignore` to help prevent accidental commits.

## Getting started to work with Azure from API side
### Background info: Azure identity-based access uses Azure Active Directory
Azure differs from AWS in how it handles API access and identity. While AWS often uses static access keys, Azure emphasizes identity-based access using Azure Active Directory (AAD), and API authentication is typically done through OAuth2 tokens issued for a service principal (app registration).

### How to obtain credentials to work with Azure
Below is a rough guide for how our team works with Azure.

The `az` CLI tool will use the following 4 environment variables:
  * AZURE_CLIENT_ID
  * AZURE_CLIENT_SECRET
  * AZURE_TENANT_ID
  * AZURE_SUBSCRIPTION_ID

We explain how our team obtains these variables below.
1. You need a paying subscription in Azure, all of the below steps assume you have secured and paid for your own Azure API access
1. Install the Azure CLI tool - See [install instructions](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
1. Login into Azure via use of the
    * `az login`
1. `cp source_me.example source_me.env`
1. Edit `source_me.env`
    * AZURE_SP_NAME
      * Choose a unique name for your "Service Principal"
1. `source source_me.env`
    * We want to ensure that the variables set in `source_me.env` are now exported in your shell session so follow up scripts can use them.
1. Create a service principal by executing
    * `./create_service_principal.sh`
        *  This will create a file `./my_azure_credentials.env` which has the below environment variables set:

                export AZURE_CLIENT_ID="REPLACE"
                export AZURE_CLIENT_SECRET="REPLACE"
                export AZURE_TENANT_ID="REPLACE"
                export AZURE_SUBSCRIPTION_ID="REPLACE"
1. `source my_azure_credentials.env`
    * We want to ensure that the variables set in `my_azure_credentials.env` are now exported in your shell session so follow up scripts can use them, this is how the `az` tool will authenticate.

## How to deploy an OpenAI model with Azure OpenAI
1. cd `openai`
1. cp `source_me_model_settings.example` `source_me_model_settings.env`
1. Edit the `source_me_model_settings.env`
1. `source source_me_model_settings.env`
    * We want to ensure that the variables set in `source_me_model_settings.env` are now exported in your shell session so follow up scripts can use them.


## Deploying OpenAI models via Azure OpenAI
* https://azure.microsoft.com/en-us/products/ai-services/openai-service

### Background
We use Azure OpenAI to deploy a service in Azure for accessing OpenAI models.
The steps are roughly:
1. Create a resource group in Azure
1. Create an Azure OpenAI Service account
1. Deploy a specific model to your account
1. Write the credentials to disk to be sourced later

### Provision a model
1. cd `openai`
1. cp `source_me_model_settings.example` `source_me_model_settings.env`
1. Edit the `source_me_model_settings.env`
    * You can leave most of the settings as they are, but you may want to change what model is deployed.
    * export MODEL_NAME="gpt-4o-mini"
    * export MODEL_VERSION="2024-07-18"
1. `source source_me_model_settings.env`
    * We want to ensure that the variables set in `source_me_model_settings.env` are now exported in your shell session so follow up scripts can use them.

###
