# Azure Partner ID Task

This Azure DevOps Pipeline task sets or updates the Azure Partner ID for ARM deployments.

## Prerequisites

- Azure CLI must be installed on the build agent
- Azure Service Connection must be configured in your pipeline

## Usage

1. Add the task to your pipeline
2. Configure an Azure service connection if you haven't already
3. Use the task in your pipeline:

```yaml
steps:
- task: PartnerIdTask@1
  inputs:
    partnerId: '123456' # Your 6-8 digit partner ID
  env:
    AZURE_SUBSCRIPTION: $(azureSubscription) # Name of your Azure service connection
```

The task will:
- Validate the Partner ID format
- Check if a Partner ID is already set
- Update or create the Partner ID as needed

## Error Handling

The task will fail if:
- The Partner ID is not a 6-8 digit number
- Azure CLI is not installed
- Azure service connection is not properly configured
