function Create-Header(){
    [CmdletBinding()]
    param(
        [Parameter(mandatory=$true)]
        [PSCustomObject]$Token
    )
<#
  Function:  Create-Header

  Purpose:  To Generically produce a header for use in calling Microsoft API endpoints

  Parameters:   -Token = (Previously Created Token Object)

  Example:  
    
     Create-Header -token $TokenObject 

#> 

           #refresh tokens about to expire
           $expirytime = ([DateTime]$Token.Expires_in).ToUniversalTime() 
           #write-debug "Expiry = $($expirytime)"
           #write-debug "Current time  = $((Get-Date).AddSeconds(10).ToUniversalTime())"

            if (((Get-Date).AddSeconds(10).ToUniversalTime()) -gt ($expirytime.AddMinutes(-2)) ) {

                # Need to initiate Refresh
                Refresh-Token -Token $Token

            }

 
            #Add the token to headers for the request
            $Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Header.Add("Authorization", "Bearer "+$Token.access_token)
            $Header.Add("Content-Type", "application/json")

            #storage requests require two different keys in the header 
            if ($Scope -eq "https://storage.azure.com/.default"){
                $Header.Add("x-ms-version", "2019-12-12")
                $Header.Add("x-ms-date", [System.DateTime]::UtcNow.ToString("R"))
            }

            #write-debug "header = $($Header)"


return  $Header


 }