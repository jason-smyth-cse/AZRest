function Set-AzureObject(){

param(
    [parameter(Mandatory = $false)]
    [string]$Subscription,
	[parameter(Mandatory = $false)]
    [string]$ResourceGroup,
	[parameter(Mandatory = $false)]
    [string]$Workspace,
    [parameter(Mandatory = $true)]
	[psobject]$AzObject
)

<#
  Function:  Set-AzureObject

  Purpose:  Changes aspects of the Id Property of an Azure object.  This allows
            Properties to be modified from the default values stored in templates.
            Typically this might be changing subscription or resourcegroup values
            for testing.

  Parameters:   -object        = The PowerShell custom object / Azure object to be modified (#[hashtable]$AzObject)
                -subscription  = The new subscription gui to deploy to
				-resourcegroup = The new resource group gui to deploy to
				-workspace 	   = The new workspace gui to deploy to


  Example:  
    
          $objectIDupdate = Set-AzureObject -AzObject $object -Subscription "2be53ae5-6e46-47df-beb9-6f3a795387b8" -ResourceGroup "rg-sentinel-v2" -Workspace "ingested-data-sentinel-v2"		  
#>

Process  {
    if ($Subscription -ne $null){  
      $IdString = Set-IDSubscription -IdString $AzObject.id -Subscription $Subscription 
      $AzObject.id = $IdString
    }

	if ($ResourceGroup -ne $null){  
      $IdString = Set-IDResourceGroup -IdString $AzObject.id -ResourceGroup $ResourceGroup 
      $AzObject.id = $IdString
    }

    if ($Workspace -ne $null){  
      $IdString = Set-IDWorkspace -IdString $AzObject.id -Workspace $Workspace 
      $AzObject.id = $IdString
    }

    #return the object
	return $AzObject
    }
}
