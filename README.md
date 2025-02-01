# Microsoft Partner ID (MPN ID) for Service Principals Task

This Azure DevOps Pipeline task sets or updates the Microsoft Partner ID (MPN ID) for ARM deployments.

Microsoft partners provide services that help customers achieve business and mission objectives using Microsoft products. When a partner acts on behalf of the customer to manage, configure, and support Azure services, the partner users will need access to the customer's environment. When partners use Partner Admin Link (PAL), they can associate their partner network ID with the credentials used for service delivery.

PAL enables Microsoft to identify and recognize partners who drive Azure customer success. Microsoft can attribute influence and Azure consumed revenue to your organization based on the service principal's permissions (Azure role) and scope (subscription, resource group, resource).

## Prerequisites

- Azure CLI (version 2.30.0 or higher) must be installed on the build agent
- Azure CLI managementpartner extension will be installed automatically if needed
- PowerShell (Windows PowerShell or PowerShell Core for cross-platform) must be installed on the build agent
- Azure Service Connection must be configured in your pipeline

## Cross-Platform Support

This task supports running on:

- Windows (using PowerShell 3+)
- Linux (using PowerShell Core)
- macOS (using PowerShell Core)

## Usage

1. Add the task to your pipeline
2. Configure an Azure service connection if you haven't already
3. Use the task in your pipeline:

```yaml
steps:
- task: PartnerIdTask@2
  inputs:
    partnerId: '123456' # Your 6-8 digit Microsoft Partner ID (MPN ID)
    azureServiceConnection: 'My-Azure-Connection' # Name of your Azure service connection
```

Note: Make sure your Azure service connection has sufficient permissions to manage Partner IDs.

The task will:

- Validate the Microsoft Partner ID (MPN ID) format
- Check if a Partner ID is already set
- Update or create the Partner ID as needed

## Error Handling

The task will fail if:

- The Microsoft Partner ID (MPN ID) is not a 6-8 digit number
- Azure CLI is not installed
- Azure service connection is not properly configured

## Troubleshooting Guide

### Common Issues and Solutions

1. "The current operating system is not capable of running this task"
   - Ensure you have PowerShell Core (pwsh) installed on Linux/macOS agents
   - For Windows agents, PowerShell 3.0 or higher is required

2. "Azure CLI is not installed or not accessible"
   - Install Azure CLI using your system's package manager
   - Windows: `winget install Microsoft.AzureCLI`
   - Linux: `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

3. "Failed to initialize Azure CLI connection"
   - Verify your Azure Service Connection has the correct permissions
   - Ensure the Service Principal has sufficient rights in Azure
   - Check if the subscription ID is valid and accessible

4. "Error checking existing Partner ID"
   - Verify network connectivity to Azure
   - Check if the managementpartner Azure CLI extension is installed
   - Ensure your Service Principal has rights to manage Partner IDs

### Logging and Debugging

The task provides detailed logging including:

- Azure CLI version information
- Current Partner ID status
- All operations performed (check/create/update)
- Detailed error messages when operations fail

Enable debug logging in your pipeline for more detailed information:

```yaml
variables:
  system.debug: true
```

## Support

If you encounter issues:

1. Check the troubleshooting guide above
2. Enable debug logging
3. Review the build logs for detailed error messages
4. Open an issue on our GitHub repository with the error details
