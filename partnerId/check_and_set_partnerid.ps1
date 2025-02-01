[CmdletBinding()]
param()

# Import VstsTask module
$modulePath = Join-Path $PSScriptRoot ([System.IO.Path]::Combine("ps_modules", "VstsTaskSdk", "VstsTaskSdk.psd1"))
if (Test-Path $modulePath) {
    Import-Module $modulePath -Verbose
} else {
    Write-Error "VstsTaskSdk.psd1 not found at $modulePath"
    exit 1
}

# Initialize Azure CLI connection
try {
    Write-Output "Initializing Azure CLI connection..."
    $endpoint = Get-VstsEndpoint -Name (Get-VstsInput -Name "azureServiceConnection" -Require)
    $subscriptionId = $endpoint.Data.subscriptionId
    $tenantId = $endpoint.Auth.Parameters.tenantid
    $clientId = $endpoint.Auth.Parameters.serviceprincipalid 
    $clientSecret = $endpoint.Auth.Parameters.serviceprincipalkey

    # Login to Azure
    $env:AZURE_CLIENT_ID = $clientId
    $env:AZURE_CLIENT_SECRET = $clientSecret
    $env:AZURE_TENANT_ID = $tenantId
    az login --service-principal -u $clientId -p $clientSecret --tenant $tenantId
    az account set --subscription $subscriptionId
} catch {
    Write-Error "Failed to initialize Azure CLI connection: $_"
    exit 1
}

# Verify Azure CLI is available
try {
    $azVersion = az version
    Write-Output "Azure CLI version: $azVersion"
} catch {
    Write-Error "Azure CLI is not installed or not accessible"
    exit 1
}

# Get input from task
$partnerId = Get-VstsInput -Name "partnerId" -Require

# Validate partnerId is a 6-8 digit number
if ($partnerId -notmatch '^\d{6,8}$') {
    Write-Error "Microsoft Partner ID (MPN ID) must be a 6-8 digit number"
    exit 1
}

Write-Output "Adding Azure CLI extension 'managementpartner'..."
az extension add --name managementpartner

Write-Output "Checking and setting Microsoft Partner ID (MPN ID)..."
try {
    # Execute the command and capture the JSON output
    $response = az managementpartner show | ConvertFrom-Json
    
    if ($response -and $response.partnerId) {
        if ($response.partnerId -eq $partnerId) {
            Write-Output "Microsoft Partner ID (MPN ID) already set. Nothing to do"
        } else {
            Write-Output "Microsoft Partner ID (MPN ID) mismatch. Updating..."
            az managementpartner create --partner-id $partnerId
        }
    } else {
        Write-Output "No Microsoft Partner ID (MPN ID) found. Creating new Microsoft Partner ID (MPN ID)..."
        az managementpartner create --partner-id $partnerId
    }
} catch {
    Write-Output "Error encountered. Creating new Microsoft Partner ID (MPN ID)..."
    az managementpartner create --partner-id $partnerId
}
