function Get-Token(){
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName="App")]
        [string]$Thumbprint,
        [Parameter(mandatory=$false)]
        [string]$Tenant,
        [Parameter(mandatory=$true)]
        [ValidateSet(
            "azure",
            "graph",
            "keyvault",
            "storage",
            "analytics"
        )][string]$Scope,
        [Parameter(mandatory=$false)]
        [string]$Proxy,
        [Parameter(mandatory=$false)]
        [PSCredential]$ProxyCredential
    )
 
<#
  Function:  Get-Token

  Purpose:  To Generically produce a token for use in calling Microsoft API endpoints

            This is an Interactive Flow for use with Refresh tokens.  For Legacy authentication that doesnt use a refresh token
            use the Get-Header function

  Parameters: 
                -Tenant     = disney.onmicrosoft.com
                -Scope      = graph / azure

                -Proxy      ="http://proxy:8080"
                -ProxyCredential = (Credential Object)

  Example:  
    
     Get-Token -scope "azure" -Tenant "disney.com" -Interactive

#> 
 
    begin {
 


 
       $ClientId       = "1950a258-227b-4e31-a9cf-717495945fc2" 
 
 
       switch($Scope){
           'azure' {$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/v2.0/token"
                    $RequestScope = "https://management.azure.com/.default"
                    $ResourceID  = "https://management.azure.com/"
                    }
           'graph' {$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/token"
                    $RequestScope = "https://graph.microsoft.com/.default"
                    $ResourceID  = "https://graph.microsoft.com"
                    }
           'keyvault'{$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/v2.0/token"
                    $RequestScope = "https://vault.azure.net/.default"
                    $ResourceID  = "https://vault.azure.net"
                    }
           'storage'{$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/v2.0/token"
                    $RequestScope = "https://storage.azure.com/.default"
                    $ResourceID  = "https://storage.azure.com/"
                    }       
           'analytics'{$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/v2.0/token"
                    $RequestScope = "https://api.loganalytics.io/.default"
                    $ResourceID  = "https://api.loganalytics.io/"
                    }                                   
           default { throw "Scope $($Scope) undefined - use azure or graph'" }
        }
 
        #Set Accountname based on Username or AppId
        if (!([string]::IsNullOrEmpty($Username))){$Accountname = $Username }
        if (!([string]::IsNullOrEmpty($AppId))){$Accountname = $AppId }
 
   
         $TokenObject = [PSCustomObject]@{
            token_type     = 'Bearer'
            token_endpoint = $TokenEndpoint
            scope          = $RequestScope
            access_token   = ''
            refresh_token  = ''
            client_id      = $clientId 
            client_assertion = ''
            client_assertion_type = ''
            code           = ''
            code_verifier  = ''
            redirect_uri   = ''
            grant_type     = ''
            expires_in     = ''
        }
    }
    
    process {
        
        # Interfactive Authentication

            $TokenObject.grant_type = "authorization_code"

             $response_type         = "code"
             $redirectUri           = [System.Web.HttpUtility]::UrlEncode("http://localhost:8400/")
             $redirectUri           = "http://localhost:8400/"
             $code_challenge_method = "S256"
             $state                 = "141f0ce8-352d-483a-866a-79672b952f8e668bc603-ea1a-43e7-a203-af3abe51e2ea"
             #$resource = [System.Web.HttpUtility]::UrlEncode("https://graph.microsoft.com")
             $RandomNumberGenerator = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
             $Bytes = New-Object Byte[] 32
             $RandomNumberGenerator.GetBytes($Bytes)
             $code_verifier = ([System.Web.HttpServerUtility]::UrlTokenEncode($Bytes)).Substring(0, 43)

             $code_challenge = ConvertFrom-CodeVerifier -Method s256 -codeVerifier $code_verifier

             $url = "https://login.microsoftonline.com/$($tenant)/oauth2/v2.0/authorize?scope=$($RequestScope)&response_type=$($response_type)&client_id=$($clientid)&redirect_uri=$([System.Web.HttpUtility]::UrlEncode($redirectUri))&prompt=select_account&code_challenge=$($code_challenge)&code_challenge_method=$($code_challenge_method)" 

               Add-Type -AssemblyName System.Windows.Forms

                $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width=440;Height=640}
                $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width=420;Height=600;Url=($url -f ($RequestScope -join "%20")) }

                $DocComp  = {
                    $Global:uri = $web.Url.AbsoluteUri        
                    if ($Global:uri -match "error=[^&]*|code=[^&]*") {$form.Close() }
                }
                $web.ScriptErrorsSuppressed = $true
                $web.Add_DocumentCompleted($DocComp)
                $form.Controls.Add($web)
                $form.Add_Shown({$form.Activate()})
                $form.ShowDialog() | Out-Null

                $queryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
                $output = @{}
                foreach($key in $queryOutput.Keys){
                    $output["$key"] = $queryOutput[$key]
                }



                $authCode=$output["code"]


    #get Access Token


         $Body = @{
              client_id = $clientId 
              code = $authCode
              code_verifier = $code_verifier
              redirect_uri = $redirectUri
              grant_type = "authorization_code"
          }


             $TokenObject.code          = $authCode
             $TokenObject.code_verifier = $code_verifier
             $TokenObject.redirect_uri  = $redirectUri


           # All Request types have create a Body for POST that will return a token

            $RequestSplat = @{
                Uri = $TokenEndpoint
                Method = “POST”
                Body = $Body 
                UseBasicParsing = $true
            }


           #Construct parameters if they exist
           if($Proxy){ $RequestSplat.Add('Proxy', $Proxy) }
           if($ProxyCredential){ $RequestSplat.Add('ProxyCredential', $ProxyCredential) }
                       
           $Response = Invoke-WebRequest @RequestSplat  
           
           $ResponseJSON = $Response | ConvertFrom-Json

           #write-debug $Response

            #Expires in states how many seconds from not the token will be valid - this needs to be referenced as a proper date/time

           $ResponseJSON.expires_in  = (Get-Date).AddSeconds([int]($ResponseJSON.expires_in) ).ToUniversalTime()
 
           $TokenObject.expires_in    = $ResponseJSON.expires_in
           $TokenObject.access_token  = $ResponseJSON.access_token
           $TokenObject.refresh_token  = $ResponseJSON.refresh_token
    }
    
    end {
 
    return  $TokenObject

    }
 
}