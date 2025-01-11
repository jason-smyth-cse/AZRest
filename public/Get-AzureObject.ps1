function Get-AzureObject(){
param(
    [parameter( Mandatory = $true, ValueFromPipeline = $true)]
    [string]$id,
    [parameter( Mandatory = $true)]
    $authHeader,
    [parameter( Mandatory = $true)]
    $apiversions
)
Process  {
    $IDArray = ($id).split("/")

    write-debug "(function Get-AzureObject) id = $id"
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

  write-debug "(function Get-AzureObject) objecttype = $objecttype"

 # There are some inconsistent objects that dont have a type property - default to deriving type from the ID
  if ($objecttype -eq $null){ $objecttype = $IDArray[$provIndex + 2]}
  
  
  #Resource Groups are also a special case without a provider
  if(($IDArray.count -eq 5)-and ($idarray[3] -eq "resourceGroups")){ 
    write-debug "(function Get-AzureObject) IDArray count = 5 setting objecttype = Microsoft.Resources/resourceGroups"
    $objecttype = "Microsoft.Resources/resourceGroups"
  }


  # Subscriptions are special too
  if(($IDArray[1] -eq 'subscriptions') -and ($idarray.Count -eq 3)){ 
    write-debug "(function Get-AzureObject) IDArray count = 3 setting objecttype = Microsoft.Resources/subscriptions"
  $objecttype = "Microsoft.Resources/subscriptions" }
  

  write-debug "(function Get-AzureObject) Array Count = $($idarray.Count )"
  
        
  # We can now get the correct API version for the object we are dealing with 
  # which is required for the Azure management URI 
 
 # There is always one object that doesn't follow the pattern!!!
  # Check to make sure that the object type has a schema api version.  If not, drop back one element

  $obApiversion = $null
  try{
    $obApiversion = $($apiversions["$($objecttype)"])
      write-debug "(function Get-AzureObject) ObjectType = $($objecttype)"
      write-debug "obapiversion = $obApiversion"
  }
  catch{
    write-warning "(function Get-AzureObject) version retreival failure with $objecttype - $($Error[0].Exception.GetType().FullName)"
  }

  if ($obApiversion){
    # 99.99% of the time this is consistent and a version will have been retrieved
  }else{

    write-debug "(function Get-AzureObject) obApiversion does not exist"

    # We now know the object type
  #$objecttype
  $objecttype  =   $objecttype.SubString(0, $objecttype.LastIndexOf('/'))
  $obApiversion = $($apiversions["$($objecttype)"])
  write-debug "(function Get-AzureObject) API Version derived as $obapiversion  for type $objecttype"
  }

  # Now I actually fetch the object from Azure
  $uri = "https://management.azure.com/$($id)?api-version=$($obApiversion)"

  # A new exception for workbooks needing an additional parameter to get content
  # &canFetchContent
  
   if ($objecttype -eq "microsoft.insights/workbooks"){ $uri = $uri + '&canFetchContent=true'}

   try {
		$object = Invoke-RestMethod -Uri $uri -Method GET -Headers $authHeader -ErrorAction Stop 
		# Only proceed with conversion if we got a valid object
		if ($object) {
				$object = ConvertTo-CleanAzureObject -azobject $object
				return $object
		}
   }
   catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $statusDescription = $_.Exception.Response.StatusDescription
        
        switch ($statusCode) {
            404 {
                Write-Warning "Resource not found: $id"
                Write-Debug "(function Get-AzureObject) 404 Not Found for URI: $uri"
                return $null
            }
            401 {
                Write-Warning "Unauthorized access to resource: $id. Please check authentication."
                Write-Debug "(function Get-AzureObject) 401 Unauthorized for URI: $uri"
                throw
            }
            403 {
                Write-Warning "Forbidden access to resource: $id. Please check permissions."
                Write-Debug "(function Get-AzureObject) 403 Forbidden for URI: $uri"
                throw
            }
            default {
                Write-Warning "Error accessing resource $id. Status code: $statusCode - $statusDescription"
                Write-Debug "(function Get-AzureObject) Error for URI: $uri - Status: $statusCode $statusDescription"
                throw
            }
        }
    }
  }
}
