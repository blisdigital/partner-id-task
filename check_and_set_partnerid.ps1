[CmdletBinding()]
param()

# Get input from task
$partnerId = Get-VstsInput -Name "partnerId" -Require

# Validate partnerId is a 6-8 digit number
if ($partnerId -notmatch '^\d{6,8}$') {
    Write-Error "Partner ID must be a 6-8 digit number"
    exit 1
}

Write-Output "Adding Azure CLI extension 'managementpartner'..."
az extension add --name managementpartner

Write-Output "Checking and setting Partner ID..."
try {
    # Execute the command and capture the JSON output
    $response = az managementpartner show | ConvertFrom-Json
    
    if ($response -and $response.partnerId) {
        if ($response.partnerId -eq $partnerId) {
            Write-Output "Partner ID already set. Nothing to do"
        } else {
            Write-Output "Partner ID mismatch. Updating..."
            az managementpartner create --partner-id $partnerId
        }
    } else {
        Write-Output "No partner ID found. Creating new partner ID..."
        az managementpartner create --partner-id $partnerId
    }
} catch {
    Write-Output "Error encountered. Creating new partner ID..."
    az managementpartner create --partner-id $partnerId
}
