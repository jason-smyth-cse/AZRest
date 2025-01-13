function Set-IDWorkspace(){
param(
    [parameter( Mandatory = $true)]
    [string]$Workspace,
    [parameter( Mandatory = $true)]
    [string]$IdString
)

<#
  Function: Set-IdSubscription

  Purpose:  Changes the subscription of the Id Property with an Azure object.  

  Parameters:   [OutputType([hashtable])]
				-object        = The PowerShell custom object / Azure object to be modified
                -workspace     = The new workspace gui to deploy to


  Example:  
    
          $object = Set-IdWorkspace -object $object -Workspace "ingested-data-sentinel"
#>
    
    
  #Get Id property and split by '/' workspace
    $IdArray = $IdString.split('/')
     
  If ($IdArray[7] -eq 'workspaces'){
    # substitute the subscription id with the new version
    $IdArray[8] = $Workspace

    #reconstruct the Id
    $id = ""
        for ($i=1;$i -lt $IdArray.Count; $i++) {
        $id = "$($id)/$($IdArray[$i])" 
    }
   $IdString = $id
  }
  return $IdString
}