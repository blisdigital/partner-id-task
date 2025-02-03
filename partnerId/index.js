const tl = require('azure-pipelines-task-lib/task');
const { exec } = require('child_process');
const util = require('util');
const execAsync = util.promisify(exec);

async function run() {
    try {
        // Get inputs
        const partnerId = tl.getInput('partnerId', true);
        const azureServiceConnection = tl.getInput('azureServiceConnection', true);

        // Validate partnerId format
        if (!/^\d{6,8}$/.test(partnerId)) {
            tl.setResult(tl.TaskResult.Failed, 'Microsoft Partner ID (MPN ID) must be a 6-8 digit number');
            return;
        }

        // Get service connection details
        const endpoint = tl.getEndpointAuthorization(azureServiceConnection, true);
        const subscriptionId = tl.getEndpointDataParameter(azureServiceConnection, 'subscriptionid', true);
        const tenantId = endpoint.parameters['tenantid'];
        const clientId = endpoint.parameters['serviceprincipalid'];
        const clientSecret = endpoint.parameters['serviceprincipalkey'];

        // Check Azure CLI version
        console.log('Checking Azure CLI version...');
        const { stdout: versionOutput } = await execAsync('az version');
        const versionJson = JSON.parse(versionOutput);
        const cliVersion = versionJson['azure-cli'];
        console.log(`Azure CLI version: ${cliVersion}`);

        const minVersion = '2.30.0';
        if (compareVersions(cliVersion, minVersion) < 0) {
            throw new Error(`Azure CLI version ${cliVersion} is below minimum required version ${minVersion}`);
        }

        // Login to Azure
        console.log('Logging in to Azure...');
        process.env.AZURE_CLIENT_ID = clientId;
        process.env.AZURE_CLIENT_SECRET = clientSecret;
        process.env.AZURE_TENANT_ID = tenantId;
        
        await execAsync(`az login --service-principal -u ${clientId} -p ${clientSecret} --tenant ${tenantId}`);
        await execAsync(`az account set --subscription ${subscriptionId}`);

        // (Re-)Install managementpartner extension
        console.log('Installing managementpartner extension...');
        await execAsync('az extension add --name managementpartner');

        // Check existing Partner ID
        console.log('Checking existing Partner ID...');
        try {
            const { stdout: partnerOutput } = await execAsync('az managementpartner show');
            const response = JSON.parse(partnerOutput);

            if (response && response.partnerId) {
                if (response.partnerId === partnerId) {
                    console.log(`Partner ID already set to ${partnerId}`);
                } else {
                    console.log(`Updating Partner ID from ${response.partnerId} to ${partnerId}`);
                    await execAsync(`az managementpartner create --partner-id ${partnerId}`);
                }
            }
        } catch {
            console.log('Creating new Partner ID...');
            await execAsync(`az managementpartner create --partner-id ${partnerId}`);
        }

        tl.setResult(tl.TaskResult.Succeeded, 'Partner ID set successfully');
    } catch (err) {
        tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

function compareVersions(a, b) {
    const partsA = a.split('.').map(Number);
    const partsB = b.split('.').map(Number);
    
    for (let i = 0; i < Math.max(partsA.length, partsB.length); i++) {
        const valueA = partsA[i] || 0;
        const valueB = partsB[i] || 0;
        if (valueA !== valueB) return valueA - valueB;
    }
    return 0;
}

run();
