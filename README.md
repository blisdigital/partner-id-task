# Microsoft Partner ID (MPN ID) for Service Principals Task

This Azure DevOps Pipeline task sets or updates the Microsoft Partner ID (MPN ID) for ARM deployments.

Microsoft partners provide services that help customers achieve business and mission objectives using Microsoft products. When a partner acts on behalf of the customer to manage, configure, and support Azure services, the partner users will need access to the customer’s environment. When partners use Partner Admin Link (PAL), they can associate their partner network ID with the credentials used for service delivery.

PAL enables Microsoft to identify and recognize partners who drive Azure customer success. Microsoft can attribute influence and Azure consumed revenue to your organization based on the service principal's permissions (Azure role) and scope (subscription, resource group, resource).

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
    partnerId: '123456' # Your 6-8 digit Microsoft Partner ID (MPN ID)
  env:
    AZURE_SUBSCRIPTION: $(azureSubscription) # Name of your Azure service connection
```

The task will:

- Validate the Microsoft Partner ID (MPN ID) format
- Check if a Partner ID is already set
- Update or create the Partner ID as needed

## Error Handling

The task will fail if:

- The Microsoft Partner ID (MPN ID) is not a 6-8 digit number
- Azure CLI is not installed
- Azure service connection is not properly configured
