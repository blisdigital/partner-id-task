# Microsoft Partner ID (MPN ID) Task for Azure DevOps

This task helps Microsoft partners set up Partner Admin Link (PAL) by associating their Microsoft Partner ID (MPN ID) with service principals used in Azure deployments.

## Why use this task?

- **Track Your Impact**: When partners use PAL, Microsoft can properly attribute Azure consumed revenue and influence to your organization
- **Automatic Association**: Automatically associates your Partner ID with the service principal used in deployments
- **Simple Configuration**: Easy to set up and integrate into your existing pipelines

## Features

- Validates Microsoft Partner ID (MPN ID) format (6-8 digits)
- Automatically installs required Azure CLI extension
- Checks existing Partner ID configuration
- Creates or updates Partner ID as needed
- Proper error handling and logging

## Requirements

- Azure CLI must be installed on the build agent
- Azure Service Connection with appropriate permissions

## Getting Started

1. Add the task to your pipeline
2. Configure an Azure service connection if you haven't already
3. Add the task to your YAML pipeline:

```yaml
steps:
- task: PartnerIdTask@2
  inputs:
    partnerId: '123456' # Your 6-8 digit Microsoft Partner ID (MPN ID)
    azureServiceConnection: 'My-Azure-Connection' # Name of your Azure service connection
```

## More Information

- [Partner Admin Link Documentation](https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/link-partner-id)
- [Microsoft Partner Network](https://partner.microsoft.com/)
