function Get-Header(){
<#
  Function:  Get-Header

  Purpose:  To Generically produce a header for use in calling Microsoft API endpoints

  Parameters:   -Username   = Username
                -Password   = password

                -AppId      = The AppId of the App used for authentication
                -Thumbprint = eg. B35E2C978F83B49C36116802DC08B7DF7B58AB08

                -Tenant     = disney.onmicrosoft.com

                -Scope      = "analytics"- data plane of log analytics
                                            "https://api.loganalytics.io/v1/workspaces"
                                            
                              "azure"    - Azure Resource Manager
                                           "https://management.azure.com/"
                                
                              "exchange"  - Microsoft Exchange Online
                                           "https://outlook.office365.com/"
                                
                              "graph"    - Microsoft Office and Mobile Device Management (Graph)
                                            "https://graph.microsoft.com/beta/groups/'

                              "keyvault" - data plane of Azure keyvaults
                                            "https://<keyvaultname>.vault.azure.net/certificates/"

                              "o365"      - Office 365 admin portal
                                            "https://admin.microsoft.com/"

                              "portal"   - api interface of the Azure portal (only supports username / password authentication)
                                            "https://main.iam.ad.ext.azure.com/api/"
                                            
                              "sharepoint" - Sharepoint
                                            "https://<Tenant>-admin.sharepoint.com"
                                                                                        
                              "storage"  - data plane of Azure storage Accounts (table)
                                            "https://<storageaccount>.table.core.windows.net/"
 
                              "teams"     - Teams admin Portal
                                            https://api.interfaces.records.teams.microsoft.com//"
                                                                                       
                              "windows"  - api interface of legacy Azure AD  (only supports username / password authentication)
                                            "https://graph.windows.net/<tenant>/policies?api-version=1.6-internal"


                -Proxy      = "http://proxy:8080" (if operating from behind a proxy)

                -ProxyCredential = (Credential Object)

                -Interactive  = suitable for use with MFA enabled accounts

  Example:  
    
     Get-Header -scope "portal" -Tenant "disney.com" -Username "Donald@disney.com" -Password "Mickey01" 
     Get-Header -scope "graph" -Tenant "disney.com" -AppId "aa73b052-6cea-4f17-b54b-6a536be5c832" -Thumbprint "B35E2C978F83B49C36611802DC08B7DF7B58AB08" 
     Get-Header -scope "azure" -Tenant "disney.com" -AppId "aa73b052-6cea-4f17-b54b-6a536be5c715" -Secret 'xznhW@w/.Yz14[vC0XbNzDFwiRRxUtZ3'
     Get-Header -scope "azure" -Tenant "disney.com" -Interactive


#> 
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName="User")]
        [string]$Username,
        [Parameter(ParameterSetName="User")]
        [String]$Password,
        [Parameter(ParameterSetName="App")]
        [Parameter(ParameterSetName="App2")]
        [string]$AppId,
        [Parameter(ParameterSetName="App")]
        [string]$Thumbprint,
        [Parameter(mandatory=$true)]
        [string]$Tenant,
        [Parameter(mandatory=$true)]
        [ValidateSet(
            "analytics",        
            "azure",
            "exchange",
            "graph",
            "keyvault",
            "o365",
            "portal",
            "sharepoint",
            "storage",
            "windows",
            "teams"
        )][string]$Scope,
        [Parameter(ParameterSetName="App2")]
        [string]$Secret,
        [Parameter(ParameterSetName="inter")]
        [Switch]$interactive=$false,
        [Parameter(mandatory=$false)]
        [string]$Proxy,
        [Parameter(mandatory=$false)]
        [PSCredential]$ProxyCredential
    )
 
 
    begin {
 
 
       $ClientId       = "1950a258-227b-4e31-a9cf-717495945fc2" 
 
 
       switch($Scope){
           'portal' {$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/token"
                    $RequestScope = "https://graph.microsoft.com/.default"
                    $ResourceID  = "74658136-14ec-4630-ad9b-26e160ff0fc6"
                    }
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
           'windows'{$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/token"
                    $RequestScope = "openid"
                    $ResourceID  = "https://graph.windows.net/"
                    }
           'teams'{$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/v2.0/token"
                    $RequestScope = "https://api.interfaces.records.teams.microsoft.com/user_impersonation"
                    $ResourceID  = "https://api.interfaces.records.teams.microsoft.com/"
                    }
           'O365'{$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/v2.0/token"
                    $RequestScope = 'https://admin.microsoft.com/.default'
                    $ResourceID  =  'https://admin.microsoft.com'
                    }
           'Exchange'{$TokenEndpoint = "https://login.microsoftonline.com/$($tenant)/oauth2/v2.0/token"
                    $RequestScope = 'https://outlook.office365.com/.default'
                    $ResourceID  =  'https://outlook.office365.com'
                    }       
           'Sharepoint'{$TokenEndpoint = "https://login.microsoftonline.com/common/oauth2/token"
                    $RequestScope = "https://$($Tenantshortname)-admin.sharepoint.com/.default"
                    $ResourceID  =  "https://$($Tenantshortname)-admin.sharepoint.com"
                    }                                                                   
           default { throw "Scope $($Scope) undefined - use azure or graph'" }
        }
 

        #Set Accountname based on Username or AppId
        if (!([string]::IsNullOrEmpty($Username))){$Accountname = $Username }
        if (!([string]::IsNullOrEmpty($AppId))){$Accountname = $AppId }
 
        
 
    }
    
    process {
        #Credit to https://adamtheautomator.com/powershell-graph-api/#Acquire_an_Access_Token_Using_a_Certificate
        # Authenticating with Certificate
        if (!([string]::IsNullOrEmpty($Thumbprint)) -And ($interactive -eq $false)){
            write-host "+++ Certificate Authentication"
 
            # Try Local Machine Certs
            $Certificate = ((Get-ChildItem -Path Cert:\LocalMachine  -force -Recurse )| Where-Object {$_.Thumbprint -match $Thumbprint});
            if ([string]::IsNullOrEmpty($Certificate)){
            # Try Current User Certs
            $Certificate = ((Get-ChildItem -Path Cert:\CurrentUser  -force -Recurse )| Where-Object {$_.Thumbprint -match $Thumbprint});
            }
            
            if ([string]::IsNullOrEmpty($Certificate)){throw "certificate not found"}
 
 
            # Create base64 hash of certificate
            $CertificateBase64Hash = [System.Convert]::ToBase64String($Certificate.GetCertHash())
          
            # Create JWT timestamp for expiration
            $StartDate = (Get-Date "1970-01-01T00:00:00Z" ).ToUniversalTime()
            $JWTExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End (Get-Date).ToUniversalTime().AddMinutes(2)).TotalSeconds
            $JWTExpiration = [math]::Round($JWTExpirationTimeSpan,0)
 
            # Create JWT validity start timestamp
            $NotBeforeExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End ((Get-Date).ToUniversalTime())).TotalSeconds
            $NotBefore = [math]::Round($NotBeforeExpirationTimeSpan,0)
 
            # Create JWT header
            $JWTHeader = @{
                alg = "RS256"
                typ = "JWT"
                x5t = $CertificateBase64Hash -replace '\+','-' -replace '/','_' -replace '='
            }
            
            # Create JWT payload
            $JWTPayLoad = @{
                aud = $TokenEndpoint
                exp = $JWTExpiration
                iss = $AppId
                jti = [guid]::NewGuid()
                nbf = $NotBefore
                sub = $AppId
            }
 
           
            # Convert header and payload to base64
            $JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json))
            $EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte)
 
            $JWTPayLoadToByte =  [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json))
            $EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte)
 
            # Join header and Payload with "." to create a valid (unsigned) JWT
            $JWT = $EncodedHeader + "." + $EncodedPayload
 
            # Get the private key object of your certificate
            $PrivateKey = $Certificate.PrivateKey
            if ([string]::IsNullOrEmpty($PrivateKey)){throw "Unable to access certificate Private Key"}
 
            # Define RSA signature and hashing algorithm
            $RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
            $HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256
 
            # Create a signature of the JWT
 
            $Signature = [Convert]::ToBase64String( $PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT),$HashAlgorithm,$RSAPadding) ) -replace '\+','-' -replace '/','_' -replace '='
            
            $JWTBytes = [System.Text.Encoding]::UTF8.GetBytes($JWT)
 
 
            # Join the signature to the JWT with "."
            $JWT = $JWT + "." + $Signature
 
       # Construct the initial JSON Body request
       $Body = @{}
       
       $Body.Add('client_id', $AppId )  # used with all 
       $Body.Add('client_assertion', $JWT)  # used with all
       $Body.Add('client_assertion_type', "urn:ietf:params:oauth:client-assertion-type:jwt-bearer")  # used with all scopes
       $Body.Add('scope', $RequestScope)  
       $Body.Add('grant_type', 'client_credentials')  
       
       switch($Scope){
           'analytics' {}  
           'azure' {}
           'graph' {
                      $Body.Add('username', $Accountname)  
                    }
           'exchange' {}           
           'keyvault' {}
           'sharepoint' {} 
           'storage' {}
           'teams' {}
           'O365' {} 
           'portal' {
                        throw "FATAL Error - portal requests only support username and password (non interactive) flows"
                    }                                                         
           'windows' {
                        throw "FATAL Error - legacty windows graph requests only support username and password (non interactive) flows"
                    }
        }# end switch
 
 
            $Url = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"
 
            # Use the self-generated JWT as Authorization
            $Header = @{
                Authorization = "Bearer $JWT"
            }
 
            # Splat the parameters for Invoke-Restmethod for cleaner code
            $PostSplat = @{
                ContentType = 'application/x-www-form-urlencoded'
                Method = 'POST'
                Body = $Body
                Uri = $Url
                Headers = $Header
            }
 
 
            #Get Bearer Token
            $Request = Invoke-RestMethod @PostSplat
            # Create header
            $Header = $null
            $Header = @{
                Authorization = "$($Request.token_type) $($Request.access_token)"
            }
 
 
        } # End Certificate Authentication
 
 
 
        # Authenticating with Password
        if (!([string]::IsNullOrEmpty($Password)) -And ($interactive -eq $false)){
 
 
        # Construct the initial JSON Body request
       $Body = @{}
       
       $Body.Add('username', $Accountname ) 
       $Body.Add('password', $Password)  
       $Body.Add('client_id', $clientId)  
       $Body.Add('grant_type', 'password')  


       
       switch($Scope){
           'portal' {
                        $Body['clientid'] = '1950a258-227b-4e31-a9cf-717495945fc2'
                        $Body.Add('resource', '74658136-14ec-4630-ad9b-26e160ff0fc6')  
            }
           'analytics' {
                        $Body.Add('scope', $RequestScope)     
            }  
           'azure' {
                        $Body.Add('resource', $RequestScope)             
           }

           'graph' {
                        $Body.Add('username', [system.uri]::EscapeDataString($ResourceID))  
                    }
           'exchange' {
                         $Body.Add('scope', $RequestScope)            
           }           
           'keyvault' {
                         $Body.Add('scope', $RequestScope)            
           }
           'sharepoint' {
                         $Body.Add('scope', $RequestScope)            
           } 
           'storage' {
                         $Body.Add('scope', $RequestScope)            
           }
           'teams' {
                         $Body.Add('scope', $RequestScope)            
           }
           'O365' {
                         $Body.Add('scope', $RequestScope)            
           }                                               
           'windows' {
                         $Body.Add('resource', [system.uri]::EscapeDataString($ResourceID))    
                    }
        }# end switch
  
        } # end password block
 
 
 
        # Authenticating with Secret
        if (!([string]::IsNullOrEmpty($Secret)) -And ($interactive -eq $false)){
 
       # Construct the initial JSON Body request
       $Body = @{}

       $Body.Add('client_id', $AppId) 
       $Body.Add('client_secret', $Secret)          
       $Body.Add('grant_type', 'client_credentials')  
       $Body.Add('scope', $RequestScope)  
 

       switch($Scope){
           'analytics' {}  
           'azure' {}
           'graph' {
                      $Body.Remove('scope')           
                      $Body.Add('resource', [system.uri]::EscapeDataString($ResourceID))  
                    }
           'exchange' {}           
           'keyvault' {}
           'sharepoint' {} 
           'storage' {}
           'teams' {}
           'O365' {} 
           'portal' {
                        throw 'FATAL Error - portal requests only support username and password (non interactive) flows'
                    }                                                         
           'windows' {}
        }# end switch
  
       } # end secret block
 
 

        # Interfactive Authentication
         if($interactive -eq $true){
         

            # Load Web assembly when needed
            # PowerShell Core has the assembly preloaded
            if (!("System.Web.HttpUtility" -as [Type])) {
                Add-Type -Assembly System.Web
            }
                     
             $response_type         = "code"
             $redirectUri           = [System.Web.HttpUtility]::UrlEncode("http://localhost:8400/")
             $redirectUri           = "http://localhost:8400/"
             $code_challenge_method = "S256"
             $state                 = "141f0ce8-352d-483a-866a-79672b952f8e668bc603-ea1a-43e7-a203-af3abe51e2ea"
             $resource = [System.Web.HttpUtility]::UrlEncode("https://graph.microsoft.com")
             $RandomNumberGenerator = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
             $Bytes = New-Object Byte[] 32
             $RandomNumberGenerator.GetBytes($Bytes)
             $code_verifier = ([System.Web.HttpServerUtility]::UrlTokenEncode($Bytes)).Substring(0, 43)
             $code_challenge = ConvertFrom-CodeVerifier -Method s256 -codeVerifier $code_verifier


             $url = "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize?scope=$($RequestScope)&response_type=$($response_type)&client_id=$($clientid)&redirect_uri=$([System.Web.HttpUtility]::UrlEncode($redirectUri))&prompt=select_account&code_challenge=$($code_challenge)&code_challenge_method=$($code_challenge_method)" 
 
             # portal requests only support username and password (non interactive) flows  
            if ($Scope -eq "portal"){

                throw "FATAL Error - portal requests only support username and password (non interactive) flows"

            }
             # portal requests only support username and password (non interactive) flows  
            if ($Scope -eq "windows"){

                throw "FATAL Error - legacty windows graph requests only support username and password (non interactive) flows"

            }

            # Load Forms when needed
            if (!("System.Windows.Forms" -as [Type])) {
                Add-Type -AssemblyName System.Windows.Forms
            }

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


            # Get Access Token

             $Body = @{
                  client_id = $clientId 
                  code = $authCode
                  code_verifier = $code_verifier
                  redirect_uri = $redirectUri
                  grant_type = "authorization_code"
              }


         
         } # end interactive block


            $RequestSplat = @{
                Uri = $TokenEndpoint
                Method = "POST"
                Body = $Body 
                UseBasicParsing = $true
            }


           #Construct parameters if they exist
           if($Proxy){ $RequestSplat.Add('Proxy', $Proxy) }
           if($ProxyCredential){ $RequestSplat.Add('ProxyCredential', $ProxyCredential) }
                       
           $Response = Invoke-WebRequest @RequestSplat  
           $ResponseJSON = $Response|ConvertFrom-Json
 
 
            #Add the token to headers for the request
            $Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Header.Add("Authorization", "Bearer "+$ResponseJSON.access_token)
            $Header.Add("Content-Type", "application/json")

            # storage requests require two different keys in the header 
            if ($Scope -eq "storage"){
                $Header.Add("x-ms-version", "2019-12-12")
                $Header.Add("x-ms-date", [System.DateTime]::UtcNow.ToString("R"))
            }

            # portal requests require two different keys in the header 
            if ($Scope -eq "portal"){
                $Header.Add("x-ms-client-request-id", "$((New-Guid).Guid)")
                $Header.Add("x-ms-session-id", "12345678910111213141516")
            }
 
    }
    
    end {
 
       return $Header 
 
    }
 
}
