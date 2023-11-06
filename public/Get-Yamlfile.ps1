function Get-Yamlfile(){
<#
  Function:  Get-Yamlfile

  Purpose:  Transforms a saved Yaml file to a Powershell Hash table

  Parameters:   -Path      = The file path for the yaml file to import.

  Example:  
    
            $object = Get-Yamlfile `-Path "C:\templates\vmachine.yaml"
#>
param(
    [parameter( Mandatory = $true)]
    [string]$Path
)

    $content = ''

    [string[]]$fileContent = Get-Content $path

    foreach ($line in $fileContent) { $content = $content + "`n" + $line }

    ConvertFrom-Yaml $content

}