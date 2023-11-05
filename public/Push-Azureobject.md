### Function:  Get-AzureObject

### Purpose:

Gets and Azure API compliant hash table / powershell object from Azure cloud objects

### Parameters:

-azobject      = A hashtable representing an azure object.
-authHeader    = A hashtable (header) with valid authentication for Azure Management
-azobject      = A hashtable (dictionary) of Azure API versions.
-unescape      = may be set to \$false to prevent the defaul behaviour of unescaping JSON

### Example:

```powershell
 Push-Azureobject -AuthHeader $authHeader -Apiversions $AzAPIVersions -azobject $azobject
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

$file = "C:\temp\app-001.json" 

Get-jsonfile -Path $file | Push-Azureobject -authHeader $authHeader -apiversions $AzAPIVersions 
```
