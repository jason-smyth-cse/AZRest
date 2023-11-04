function Refresh-Token {
<#
  Function:  Refresh-Token

  Purpose:  Refreshes a token that supports Refresh tokens

  Parameters: 
                -Token     = Token object

  Example:  
    
     Refresh-Token -token $AuthToken

#> 
    [CmdletBinding()]
    param(
        [Parameter(mandatory=$true)]
        [PSCustomObject]$Token
    )
 

    # We have a previous refresh token. 
    # use it to get a new token

   $redirectUri = $([System.Web.HttpUtility]::UrlEncode($Token.redirect_uri))   


    # Refresh the token
    #get Access Token

    $body = "grant_type=refresh_token&refresh_token=$($Token.refresh_token)&redirect_uri=$($redirectUri)&client_id=$($Token.clientId)"

    $Response = $null
    try{
    $Response = Invoke-RestMethod $Token.token_endpoint  `
        -Method Post -ContentType "application/x-www-form-urlencoded" `
        -Body $body 
    }
    catch{
    throw "token refresh failed"
    }

    if ($Response){

        $Token.expires_in  = (Get-Date).AddSeconds([int]($Response.expires_in) ).ToUniversalTime()
        $Token.access_token  = $Response.access_token
        $Token.refresh_token  = $Response.refresh_token    

    }


} 