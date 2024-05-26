param (
    [string]$configPath
 )

# Read from file passed as parameter
$configFileContent = Get-Content -Path $configPath | ConvertFrom-Json -AsHashtable

Import-Module -Name "./functions.psm1" -Verbose

# Choose dir
$projectDirectory = Get-ProjectDir

# Choose project title
$projectTitle = Get-ProjectTitle

$destinationPath = Join-Path -Path $projectDirectory -ChildPath $projectTitle

# Choose template
$projectTemplate = Get-UserTemplateOption

if (($projectTemplate -ne 1) -and ($projectTemplate -ne 2)) {
    Write-Error "Invalid projectTemplate. Please choose either 1 or 2.";
    return;
}

$isBlankTemplate = ($projectTemplate -eq "1") ? $true : $false;

Build-Project -isBlank $isBlankTemplate -destinationPath $destinationPath -appName $projectTitle -configFileContent $configFileContent
