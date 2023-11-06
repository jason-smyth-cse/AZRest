### Function:  Push-ObjectDirectorytoAzure

### Purpose:

Deploys a directory of backed up JSON represenations of objects to Azure

### Parameters:

-TemplateDirectory = The local path to a directory of backed up JSON objects.
-authHeader        = A hashtable (header) with valid authentication for Azure Management
-AZApiversions     = A hashtable (dictionary) of Azure API versions (see Get-AzureAPIVersions).
-Subscription      = (optional) dynamically change subscription during deployment

### Example:

```powershell
 Push-ObjectDirectorytoAzure -AuthHeader $authHeader -Apiversions $AzAPIVersions -azobject $azobject
```

### General Usage:

This module requires a valid header with write access to the identified Azure subscription.  

Note the requirement for the APIVersions dictionary object which must have been created earlier using the Get-AzureAPIVersions function.  This will provide the function a reference table to select the latest API versions for a given object type.  

```powershell
#Get an Authorised Header

$authHeader = Get-Header -scope "azure"  -Tenant "laurierhodes.info" -AppId "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" `
                         -secret $secret

# Retrieve an up to date list of namespace versions (once per session)

if (!$AzAPIVersions){$AzAPIVersions = Get-AzureAPIVersions -header $authHeader -SubscriptionID "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"}

$backupfolder = "C:\myazurebackup" 

 Push-ObjectDirectorytoAzure -TemplateDirectory $backupfolder -AuthHeader $authHeader -Apiversions $AzAPIVersions -azobject $azobject
```
