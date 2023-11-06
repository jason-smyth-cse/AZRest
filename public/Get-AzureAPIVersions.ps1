function Get-AzureAPIVersions(){
<#
  Function:  Get-AzureAPIVersions

  Purpose:  Constructs a dictionary of current Azure namespaces

  Parameters:   -SubscriptionId      = The subscription ID of the environment to connect to.
                -Header              = A hashtable (header) with valid authentication for Azure Management

  Example:  
    
             Get-AzureAPIVersions = Get-AnalyticsWorkspaceKey `
                                      -Header $header `
                                      -SubscriptionId "ed4ef888-5466-401c-b77a-6f9cd7cc6815" 
#>
param(
    [parameter( Mandatory = $true)]
    [hashtable]$header,
    [parameter( Mandatory = $true)]
    [string]$SubscriptionID
)

    $dict = @{}
       
    Try{
      $uri = "https://management.azure.com/subscriptions/$($SubscriptionID)/providers/?api-version=2015-01-01"
      $result = Invoke-RestMethod -Uri $uri -Method GET -Headers $Header 
      
    $namespaces = $result.value 

    foreach ($namespace in $namespaces){
       foreach ($resource in $namespace.resourceTypes){

       #Add Provider Plus Resource Type
        $dict.Add("$($namespace.namespace)/$($resource.resourceType)",$($resource.apiVersions | Get-latest) )
       }
     }

     #return dictionary
     $dict      
    } catch {
      # catch any authentication or api errors
      Throw "Get-AzureAPIVersions failed - $($_.ErrorDetails.Message)"
    }

}