function Set-IDResourceGroup(){
param(
    [parameter( Mandatory = $true)]
    [string]$ResourceGroup,
    [parameter( Mandatory = $true)]
    [string]$IdString
)

<#
  Function: Set-IdResourceGroup

  Purpose:  Changes the resource group name of the Id Property with an Azure object.  

  Parameters:   [OutputType([hashtable])]
				-object        	 = The PowerShell custom object / Azure object to be modified
                -resource group  = The new resource group gui to deploy to


  Example:  
    
          $object = Set-IdResourceGroup -object $object -ResourceGroup "rg-sentinel"
#>
    
    
  #Get Id property and split by '/' resource group
    $IdArray = $IdString.split('/')
     
  If ($IdArray[3] -eq 'resourceGroups'){
    # substitute the subscription id with the new version
    $IdArray[4] = $ResourceGroup

    #reconstruct the Id
    $id = ""
        for ($i=1;$i -lt $IdArray.Count; $i++) {
        $id = "$($id)/$($IdArray[$i])" 
    }
   $IdString = $id
  }
  return $IdString
}