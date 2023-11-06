### Function:  Remove-AzureObject

### Purpose:

Deletes an azure object.

### Parameters:

-id          = The PowerShell custom object / Azure object to be modified
-authHeader  = A hashtable (header) with valid authentication for Azure Management
-apiversions  = A hashtable (dictionary) of Azure API versions.


### Example:

```powershell
   Remove-AzureObject -AuthHeader $authHeader -Apiversions $AzAPIVersions -id $azobjectID
```

### General Usage:

This module requires a valid header with write access to the identified Azure Resource Group.  

Note the requirement for the APIVersions dictionary object which must have been created earlier using the Get-AzureAPIVersions function.  This will provide the function a reference table to select the latest API versions for a given object type.  

```powershell
#Get an Authorised Header

$authHeader = Get-Header -scope "azure"  -Tenant "laurierhodes.info" -AppId "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" `
                         -secret $secret

# Retrieve an up to date list of namespace versions (once per session)

if (!$AzAPIVersions){$AzAPIVersions = Get-AzureAPIVersions -header $authHeader -SubscriptionID "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"}

#Set my object ID
$azobjectID = '/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxx/resourceGroups/Sentinel/providers/Microsoft.Web/sites/Sentinal-Enrichment'

# Remove the object
Remove-AzureObject -AuthHeader $authHeader -Apiversions $AzAPIVersions -id $azobjectID


```
