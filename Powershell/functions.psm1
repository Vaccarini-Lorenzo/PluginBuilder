# Load config
$config = Get-Content -Path '../config.json' | ConvertFrom-Json

function Build-Project {
    param (
        [string]$destinationPath,
        [string]$appName,
        [hashtable]$configFileContent,
        [bool]$isBlank = $true 
    )

    $repositoryUrl = if ($isBlank) { $config.blankTemplateRepositoryUrl } else { $config.RAGTemplateRepositoryUrl }
    $cloneStatus = Get-Template -repositoryUrl $repositoryUrl -destinationPath $destinationPath
    if ($cloneStatus -ne 0) {
        return;
    }

    Update-ProjectName -projectDirectory $destinationPath -appName $appName
    if ($isBlank){
        Write-Host "Successfully created a blank template at $destinationPath"
        return;
    }
    $azureParameters = Get-PluginParameters -existingParameters $configFileContent
    Write-PluginParametersToEnv -projectDirectory $destinationPath -parameters $azureParameters
    Write-Host "Successfully created a RAG template at $destinationPath"
    return;
}

function Get-Template {
    param (
        [string]$repositoryUrl,
        [string]$destinationPath
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git is not installed. Please install Git before cloning the repository.";
        return 1;
    }

    # Clone the repository
    git clone $repositoryUrl $destinationPath -q

    if($?){
        Write-Host "Repository cloned successfully."
        return 0;
    } else {
        Write-Error "Error cloning the template repository."
        return 1;
    }
}

function Get-ProjectDir {
    $projectDirectory = Read-Host "Enter the project directory (press Enter for current directory): "
    if ([string]::IsNullOrWhiteSpace($projectDirectory)) { $projectDirectory = $PWD.Path }
    return $projectDirectory
}

function Get-ProjectTitle {
    $projectTitle = Read-Host "Enter the project title"
    if ([string]::IsNullOrWhiteSpace($projectTitle)) { $projectTitle = "DemoProject" }
    return $projectTitle
}

function Get-UserTemplateOption {
    $projectTemplate = Read-Host "Choose an option:
    1) Blank Template
    2) Azure RAG"
    return $projectTemplate
}

function Update-ProjectName {
    param (
        [string]$projectDirectory,
        [string]$appName
    )
    if (-not (Test-Path $projectDirectory)) {
        Write-Error "Project directory does not exist."
        return 1;
    }
    # Navigate to the env folder
    $envFolderPath = Join-Path -Path $projectDirectory -ChildPath "env"
    Set-Location -Path $envFolderPath -ErrorAction Stop
    # Write APP_NAME to .env file
    $envFilePath = Join-Path -Path $envFolderPath -ChildPath ".env.local"
    Add-Content -Path $envFilePath -Value "APP_NAME=$appName"
    Write-Host "Successfully updated APP_NAME in .env file. (APP_NAME=$appName)"
}

function Get-PluginParameters {
    param (
        [object]$existingParameters
    )

    $parameters = @{}

    $keys = $existingParameters.Keys
    
    $missingParameters = @()
    $parametersToCheck = @(
        "AZURE_OPENAI_SERVICE_NAME",
        "AZURE_OPENAI_DEPLOYMENT_NAME",
        "AZURE_OPENAI_API_VERSION",
        "AZURE_OPENAI_API_KEY",
        "AZURE_SEARCH_ENDPOINT",
        "AZURE_SEARCH_ADMIN_KEY",
        "AZURE_SEARCH_INDEX_NAME",
        "DEPLOYMENT_NAME"
    )

    foreach ($parameter in $parametersToCheck) {
        if ($keys -contains $parameter) {
            Write-Debug "Found existing parameter: $parameter"
            $parameters[$parameter] = $existingParameters[$parameter]
            continue
        };
        $missingParameters += $parameter
    }

    Write-Debug "Missing parameters: $missingParameters"

    $missingParameters | ForEach-Object {
        $parameterValue = Read-Host "Enter the value for $_"
        $parameters[$_] = $parameterValue
    }

    Write-Debug "Final parameters:"
    Write-Debug ($parameters | Format-Table | Out-String)

    return $parameters
}

function Write-PluginParametersToEnv {
    param (
        [string]$projectDirectory,
        [object]$parameters
    )
    try {
        # Check if the project directory exists
        if (-not (Test-Path $projectDirectory)) {
            throw "Project directory does not exist."
        }
        # Navigate to the env folder
        $envFolderPath = Join-Path -Path $projectDirectory -ChildPath "env"
        Set-Location -Path $envFolderPath -ErrorAction Stop
        # Write parameters to .env.local file
        $envFilePath = Join-Path -Path $envFolderPath -ChildPath ".env.local"
        $parameters.Keys | ForEach-Object { 
            $content = "$_=$($parameters[$_])"
            Add-Content -Path $envFilePath -Value $content
        }
        Write-Host "Successfully wrote parameters to .env.local file."
        # $content = ($parameters | ConvertTo-Json).replace(": ", "=")
        # Write-Host "Content $content"
        # Add-Content -Path $envFilePath -Value $content
        # Write-Host "Successfully wrote parameters to .env.local file."
    }
    catch {
        Write-Host "Failed to write parameters to .env.local file: $_"
    }
}