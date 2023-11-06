function Remove-AzureObject(){

param(
    [parameter( Mandatory = $true, ValueFromPipeline = $true)]
    [string]$id,
    [parameter( Mandatory = $true)]
    $authHeader,
    [parameter( Mandatory = $true)]
    $apiversions
)

<#
  Function:  Remove-AzureObject

  Purpose:  Deletes an azure object

  Parameters:   -id            = A string ID representing an azure object.
                -authHeader    = A hashtable (header) with valid authentication for Azure Management

  Example:  
    
             Remove-AzureObject -AuthHeader $authHeader -Apiversions $AzAPIVersions -azobject $azobject
#> 

Process  {
     $IDArray = ($id).split("/")
     # $namespace = $IDArray[6]
     # $resourcetype = $IDArray[7]

     # Find the last 'provider' element
     for ($i=0; $i -lt $IDArray.length; $i++) {
      if ($IDArray[$i] -eq 'providers'){$provIndex =  $i}
     }

     $arraykey = "$($IDArray[$provIndex + 1])/$($IDArray[$provIndex + 2])"


   #type can be overloaded - include if present
   if($IDArray[$provIndex + 4]){ 
     if($apiversions["$($arraykey)/$($IDArray[$provIndex + 4])"]){ $arraykey = "$($arraykey)/$($IDArray[$provIndex + 4])" } 
   }
     
     #Resource Groups are a special case without a provider
     if($IDArray.count -eq 5){ $arraykey = "Microsoft.Resources/resourceGroups"}
     
     $uri = "https://management.azure.com/$($id)?api-version=$($apiversions["$($arraykey)"])"

    Invoke-RestMethod -Uri $uri -Method DELETE -Headers $authHeader 

  }

}