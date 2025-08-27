# Overview
Scripts in this directory help to create an instance of Azure OpenAI Service and deploy a model.
## Usage
1. `cp source_me_model_settings.example source_me_model_settings.env`
1. [Optional] Edit `source_me_model_settings.env` and update the model you want to deploy.
1. `source source_me_model_settings.env`
1. Run: `./provision.sh`
   * If above is successful it will create a file: `SECRET_my_azure_model_credentials.env`
   * You can source this file to set environment variables to access the model you provisioned.
1. Test if the model is running:
   * `source SECRET_my_azure_model_credentials.env`
   * `./test_llm_working.sh`

## Configure Konveyor AI
1. Let's assume you have a `SECRET_my_azure_model_credentials.env` file with contents like below:
```
export AZURE_OPENAI_ENDPOINT=https://jmatthews.openai.azure.com/
export AZURE_OPENAI_DEPLOYMENT=jmatthews-gpt-4o-mini-deployment
export AZURE_OPENAI_API_VERSION=2024-04-01-preview
export AZURE_OPENAI_API_KEY=349b1mysecretkeydataa78757d4
```
1. Open the Konveyor AI configuration file, `provider-settings.yaml` and set a stanza like below:

```yaml
  AzureChatOpenAI: &active
    environment:
      AZURE_OPENAI_API_KEY: "349b1mysecretkeydataa78757d4" # Required
    provider: AzureChatOpenAI
    args:
      azureOpenAIApiInstanceName: "jmatthews"
      azureOpenAIApiDeploymentName: "jmatthews-gpt-4o-mini-deployment"
      openAIApiVersion: "2024-04-01-preview"
```
  * Note that azureOpenAIApiInstanceName comes from `export OPENAI_RESOURCE_NAME="${PREFIX}"` in `source_me_model_settings.env`


## Notes:
### exceeded token rate limit
When we deploy a model, we are specifying a token limit via: ```--capacity 500``` in `deploy_model.sh`.  For that example, the token per minute would be 500k tokens per minute.  If you need to raise the limit, you can tweak this script.  It's related to the below error message.

```
Error callling stream() RateLimitError: 429 Requests to the ChatCompletions_Create Operation under Azure OpenAI API version 2024-04-01-preview have exceeded token rate limit of your current OpenAI S0 pricing tier. Please retry after 60 seconds. Please go here: https://aka.ms/oai/quotaincrease if you would like to further increase the default rate limit. For Free Account customers, upgrade to Pay as you Go here: https://aka.ms/429TrialUpgrade.

Troubleshooting URL: https://js.langchain.com/docs/troubleshooting/errors/MODEL_RATE_LIMIT/
 {status: 429, headers: _Headers, requestID: null, error: {…}, code: '429', …}
 ```
