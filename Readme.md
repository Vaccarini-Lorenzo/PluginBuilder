# Project Name

## Disclaimer
The following project has as base two templates which are currently stored in private repositories. <br>
Once thoroughly tested, repositories will be set to public.

## Description
This project is a M365 plugin builder that currently supports two templates: a blank template and a RAG (Retrieval Augmented Generation) template. 

## How to build a project
Currently only a Powershell script is available.<br>
Run
`.\generate-template.ps1 -configPath [optional config file for RAG]`

## Available Templates
- Blank template
- RAG (Retrieval Augmented Generation) template

### Blank Template Configuration
It doesn't need configuration at all but at the same time it doesn't provide much out of the box. The template will just set-up your project with a `DataController`, and a `CardController`. <br>
The business logic must be implemente form the ground up.

### RAG Template Configuration
To use the RAG template, you need to provide the following configuration data:
- `AZURE_OPENAI_SERVICE_NAME`: The name of your Azure OpenAI service. For example, "OpenAI-PluginDev".
- `AZURE_OPENAI_DEPLOYMENT_NAME`: The name of your Azure OpenAI deployment. For example, "text-embeding-ada-002".
- `AZURE_OPENAI_API_KEY`: Your Azure OpenAI API key.
- `AZURE_SEARCH_ENDPOINT`: The endpoint URL of your Azure search service. For example, "https://searchservice.search.windows.net".
- `AZURE_SEARCH_ADMIN_KEY`: The admin key of your Azure search service.
- `AZURE_SEARCH_INDEX_NAME`: The name of the search index in your Azure search service. For example, "Search-Index-Name".
- `DEPLOYMENT_NAME`: The name of the RAG deployment. For example, "gpt-35-turbo".

Please make sure to provide the correct values for each configuration variable before using the RAG template.

With the flag `-pathConfig` it's possible to skip the interactive RAG section, providing the path to a JSON file containing the config data.


### Run project
#### Requisites
- [Node.js 18.x](https://nodejs.org/download/release/v18.18.2/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Teams Toolkit](https://marketplace.visualstudio.com/items?itemName=TeamsDevApp.ms-teams-vscode-extension)
- You will need a Microsoft work or school account with [permissions to upload custom Teams applications](https://learn.microsoft.com/microsoftteams/platform/concepts/build-and-test/prepare-your-o365-tenant#enable-custom-teams-apps-and-turn-on-custom-app-uploading). The account will also need a Microsoft Copilot for Microsoft 365 license to use the extension in Copilot.
- [Azure subscription](https://portal.azure.com) (**Only RAG template**)
- Access to Azure OpenAI resources (**Only RAG template**)

#### Deploy locally
- Log into you Teams Toolkit extension
- Run from `.vscode/lauch.json`