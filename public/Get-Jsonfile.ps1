<#
  Function:  Get-JSONfile

  Purpose:  Transforms a saved Yaml file to a Powershell Hash table

  Parameters:   -Path      = The file path for the json file to import.

  Example:  
    
            $object = Get-JSONfile `-Path "C:\templates\vmachine.json"
#>
function Get-Jsonfile(){
param(
    [parameter( Mandatory = $true)]
    [string]$Path
)

    [string]$content = $null

    [string]$content = Get-Content -Path $path -Raw 
    
    if ( Get-TypeData -TypeName "System.Array" ){
       Remove-TypeData System.Array # Remove the redundant ETS-supplied .Count property
    }

    $jsonobj =  ($content  | ConvertFrom-Json )

    $AzObject = ConvertTo-HashTable -InputObject $jsonobj

    
    $AzObject
}