### Function:  Set-AzureObject

### Purpose:

Changes aspects of the Id Property of an Azure object.  This allows Properties to be modified from the default values stored in templates.
Typically this might be changing subscription or resourcegroup values for testing.\

Currently this only supports changing subscriptions on objects.

### Parameters:

-object        = The PowerShell custom object / Azure object to be modified
-subscription  = The new subscription gui to deploy to

### Example:

```powershell
  $object = Set-AzureObject -object $object -Subscription "2be53ae5-6e46-47df-beb9-6f3a795387b8"
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


# Get the JSON Definition
$object = Get-Jsonfile -Path $PolicyFile

# Alter the subscription on the resource ID for my testing
Set-AzureObject -Azobject $object -Subscription "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Deploy the Policy Definition
Push-AzureObject -azobject $hashobject -authHeader $authHeader -apiversions $AzAPIVersions


```
