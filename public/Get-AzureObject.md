### Function:  Get-AzureObject

### Purpose:

Gets and Azure API compliant hash table / powershell object from Azure cloud objects

### Parameters:

-apiversions   = A hashtable representing current API versions
-authHeader    = A hashtable (header) with valid authentication for Azure Management
-id            = An Azure object reference id (string).

### Example:

`$object = Get-Azureobject -AuthHeader $authHeader -Apiversions $AzAPIVersions -id $azobject`

### General Usage:

This module requires a valid header with read access to the identified Azure object in its subscription.  

Note the requirement for the APIVersions dictionary object which must have been created earlier using the Get-AzureAPIVersions function.  This will provide the function a reference table to select the latest API versions for a given object type.  

```powershell
#Get an Authorised Header

$authHeader = Get-Header -scope "azure"  -Tenant "laurierhodes.info" -AppId "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX" `
                         -secret $secret

# Retrieve an up to date list of namespace versions (once per session)

if (!$AzAPIVersions){$AzAPIVersions = Get-AzureAPIVersions -header $authHeader -SubscriptionID "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"}

$id='/subscriptions/XXXXXXXX-XXXXXXX/resourceGroups/rg-security/providers/Microsoft.Insights/dataCollectionRules/syslogapp-001'

$object = $null
$object =    Get-Azureobject -AuthHeader $authHeader -apiversions $AzAPIVersions -id $id

Out-File -FilePath "C:\temp\myapp-001a.json" -InputObject (convertto-json -InputObject $object -Depth 10) -Force 
```

### Coding Notes:

The largest part of the function is deriving what type of object is represented by the passed ID string.  Once the object type is determined, the latest API version can be gained from the '$AzAPIVersions' dictionary.

The final step utillises the private 'ConvertTo-CleanAzureObject' function which removes ReadOnly properties to aid in the redeployment of the object as a potential template.  This 'ConvertTo-CleanAzureObject' function is likely to need updating as additional Azure object types are tested for deployment & new read-only properties are discovered..
