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

# Verify Azure CLI version
try {
    $azVersionJson = az version | ConvertFrom-Json
    $cliVersion = $azVersionJson.'azure-cli'
    Write-Output "Azure CLI version: $cliVersion"
    
    # Convert version string to version object for comparison
    $minVersion = [System.Version]"2.30.0"
    $currentVersion = [System.Version]$cliVersion
    
    if ($currentVersion -lt $minVersion) {
        Write-Error "Azure CLI version $cliVersion is below minimum required version $minVersion. Please upgrade Azure CLI."
        exit 1
    }

    # Check managementpartner extension
    Write-Output "Checking Azure CLI extension 'managementpartner'..."
    $extOutput = az extension show --name managementpartner 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Management Partner extension not found. Installing..."
        az extension add --name managementpartner
    } else {
        $extVersion = ($extOutput | ConvertFrom-Json).version
        Write-Output "Management Partner extension version: $extVersion"
    }
} catch {
    Write-Error "Azure CLI is not installed or not accessible: $($_.Exception.Message)"
    exit 1
}

# Get input from task
$partnerId = Get-VstsInput -Name "partnerId" -Require

# Validate partnerId is a 6-8 digit number
if ($partnerId -notmatch '^\d{6,8}$') {
    Write-Error "Microsoft Partner ID (MPN ID) must be a 6-8 digit number"
    exit 1
}


Write-Output "Checking and setting Microsoft Partner ID (MPN ID)..."
try {
    # Execute the command and capture the JSON output
    $showOutput = az managementpartner show 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Error checking existing Partner ID: $showOutput"
        throw
    }
    
    $response = $showOutput | ConvertFrom-Json
    
    if ($response -and $response.partnerId) {
        if ($response.partnerId -eq $partnerId) {
            Write-Output "Microsoft Partner ID (MPN ID) already set to $partnerId. Nothing to do."
        } else {
            Write-Output "Microsoft Partner ID (MPN ID) mismatch (current: $($response.partnerId), new: $partnerId). Updating..."
            $updateOutput = az managementpartner create --partner-id $partnerId 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to update Partner ID: $updateOutput"
                exit 1
            }
            Write-Output "Successfully updated Partner ID to $partnerId"
        }
    } else {
        Write-Output "No Microsoft Partner ID (MPN ID) found. Creating new Microsoft Partner ID (MPN ID)..."
        $createOutput = az managementpartner create --partner-id $partnerId 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create Partner ID: $createOutput"
            exit 1
        }
        Write-Output "Successfully created Partner ID $partnerId"
    }
} catch {
    Write-Warning "Error details: $($_.Exception.Message)"
    Write-Output "Attempting to create new Microsoft Partner ID (MPN ID)..."
    try {
        $createOutput = az managementpartner create --partner-id $partnerId 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create Partner ID: $createOutput"
            exit 1
        }
        Write-Output "Successfully created Partner ID $partnerId"
    } catch {
        Write-Error "Failed to set Partner ID after multiple attempts: $($_.Exception.Message)"
        exit 1
    }
}
