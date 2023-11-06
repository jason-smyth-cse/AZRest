function Set-AzureObject(){
<#
  Function:  Set-AzureObject

  Purpose:  Changes aspects of the Id Property of an Azure object.  This allows
            Properties to be modified from the default values stored in templates.
            Typically this might be changing subscription or resourcegroup values
            for testing.

  Parameters:   -object        = The PowerShell custom object / Azure object to be modified
                -subscription  = The new subscription gui to deploy to


  Example:  
    
          $object = Set-AzureObject -object $object -Subscription "2be53ae5-6e46-47df-beb9-6f3a795387b8"
#> 
param(
    [parameter( Mandatory = $false)]
    [string]$Subscription,
    [parameter( Mandatory = $true)]
    [hashtable]$AzObject
)



    if ($Subscription){  
      $IdString = Set-IdSubscription -IdString $AzObject.id -Subscription $Subscription 
      $AzObject.id = $IdString
    }

    #return the object
     $AzureObject

}
