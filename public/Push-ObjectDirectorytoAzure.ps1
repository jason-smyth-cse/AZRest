function Push-ObjectDirectorytoAzure(){
param(
    [parameter( Mandatory = $true, ValueFromPipeline = $true)]
    $TemplateDirectory,
    [parameter( Mandatory = $true)]
    $authHeader,
    [parameter( Mandatory = $true)]
    $AzAPIVersions,
    [parameter( Mandatory = $false)]
    [string]$Subscription
)


Function GenerateStrongPassword (){
    [CmdletBinding()]
    param(
        [Parameter(mandatory=$true)]
        [int]$PasswordLength
    )

    Add-Type -AssemblyName System.Web
    $PassComplexCheck = $false
    do {
    $newPassword=[System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
    If ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
    -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
    -and ($newPassword -match "[\d]") `
    -and ($newPassword -match "[^\w]")
    )
    {
    $PassComplexCheck=$True
    }
    } While ($PassComplexCheck -eq $false)
    return $newPassword
}



Process  {

  # Get a handle for each file in the directory tree
  $files = Get-ChildItem $TemplateDirectory -Filter "*.json"  -Recurse

  #Deployments need to be ordered based on the number of elements in their Id as Azure is an hierachy
  #Resource Groups must be deployed before child objects etc.
  #We need to order all the json files based on the number of elements in their Id
  
  Class AzTemplate{
      [String]$TemplatePath
      [Int]$ElementCount
  }

  $DeploymentArray = @()
     

    for ($i=0; $i -lt $files.Count; $i++) {

         $objtemplate = Get-Content -Raw -Path $files[$i].FullName | ConvertFrom-Json

         # count how many elements in the object Id

        $ElementCount = (($objtemplate.id). ToCharArray() | Where-Object {$_ -eq '/'} | Measure-Object). Count

        $tempobj = New-Object AzTemplate 
        $tempobj.templatepath = $files[$i].FullName
        $tempobj.elementcount = $ElementCount

        # The element count determines the install order of Azure services - IaaS needs some tweaking to get some elements installed before others.
        if ($objtemplate.type -eq "Microsoft.Compute/virtualMachines"){$tempobj.elementcount = ($charCount +1)}

        $DeploymentArray += $tempobj
    }

    #Sort All Azure objects from smallest count of elements in Id string to largest
    $DeploymentArray = $DeploymentArray | sort-object "ElementCount"


    foreach ($aztemplate in $DeploymentArray){

        

       $deploymentobject = Get-Content -Raw -Path $aztemplate.templatepath | ConvertFrom-Json 

       # check for Virtual Machine objects
       # these cannot be deployed without a password so assign a random password for deployment
       # admins will need to reset the passwords later
       
       if ($deploymentobject.type -eq  "Microsoft.Compute/virtualMachines" ){
         $deploymentobject.properties.osProfile | Add-Member -MemberType NoteProperty -Name 'adminPassword' -Value (GenerateStrongPassword 12)
       }
       
       $deploymentobject | Push-Azureobject -authHeader $authHeader -apiversions $AzAPIVersions 
    }

 

  } #End Process

}