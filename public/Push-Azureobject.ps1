<#
  Function:  Push-Azureobject

  Purpose:  Pushes and Azure API compliant hash table to the cloud

  Parameters:   -azobject      = A hashtable representing an azure object.
                -authHeader    = A hashtable (header) with valid authentication for Azure Management
                -azobject      = A hashtable (dictionary) of Azure API versions.
                -unescape      = may be set to $false to prevent the defaul behaviour of unescaping JSON

  Example:  
    
             Push-Azureobject -AuthHeader $authHeader -Apiversions $AzAPIVersions -azobject $azobject
#> 
function Push-Azureobject(){
param(
    [parameter( Mandatory = $true, ValueFromPipeline = $true)]
    $azobject,
    [parameter( Mandatory = $true)]
    $authHeader,
    [parameter( Mandatory = $true)]
    $apiversions,
    [parameter( Mandatory = $false)]
    [bool]$unescape=$true
)


Process  {
    $IDArray = ($azobject.id).split("/")

  # Because object types can be overloaded from root namespaces a bit of testing is required
  # to validate what the object type is.
  # The last provider element in the string is always the root namespace so we have to find
  # the last 'provider' element
  
   for ($i=0; $i -lt $IDArray.length; $i++) {
	   if ($IDArray[$i] -eq 'providers'){$provIndex =  $i}
   }

  # $provIndex references where the last occurence of 'provider' is in the Id string
  # we construct the resource type from stacking elements from the ID string

  $elementcount=1
  $providertype = @()

  # Starting at the provider, until the end of the string, stack each potential overload if it exists
  for ($i=$provIndex; $i -lt $IDArray.length; $i++) {
    switch($elementcount){
     {'2','3','5','7','9' -contains $_} { $providertype += $IDArray[$i]}
     default {}
    }
    $elementcount = $elementcount + 1
  }

  # We now know the object type
  $objecttype  = $providertype -join "/"

 # There are some inconsistent objects that dont have a type property - default to deriving type from the ID
  if ($objecttype -eq $null){ $objecttype = $IDArray[$provIndex + 2]}
  #Resource Groups are also a special case without a provider
  if($IDArray.count -eq 5){ $objecttype = "Microsoft.Resources/resourceGroups"}
   
  # We can now get the correct API version for the object we are dealing with 
  # which is required for the Azure management URI 
  $uri = "https://management.azure.com$($azobject.id)?api-version=$($apiversions["$($objecttype)"])"
   
   # The actual payload of the API request is simply deployed in json
   $jsonbody =  ConvertTo-Json -Depth 50 -InputObject $azobject 
   
   if ($unescape -eq $true){
     # Invoke-RestMethod -Uri $uri -Method PUT -Headers $authHeader -Body $( $jsonbody  | % { [System.Text.RegularExpressions.Regex]::Unescape($_) })   
    Invoke-RestMethod -Uri $uri -Method PUT -Headers $authHeader -Body $jsonbody  
   }
   else  
   {
      Invoke-RestMethod -Uri $uri -Method PUT -Headers $authHeader -Body $jsonbody   
   }
   
  }

}