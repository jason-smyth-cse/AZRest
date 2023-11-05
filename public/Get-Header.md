### Function:  Get-Header

### Purpose:

To Generically produce a header for use in calling Microsoft API endpoints

### Parameters:

-Username = Username
-Password = password         
-AppId     = The AppId of the App used for authentication
-Thumbprint = eg. B35E2C978F83B49C36116802DC08B7DF7B58AB08
-Tenant     = disney.onmicrosoft.com
-Scope      = 

              "analytics"- data plane of log analytics
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

-Proxy           = "http://proxy:8080" (if operating from behind a proxy)
-ProxyCredential = (Credential Object)
-Interactive     = suitable for use with MFA enabled accounts

### Example:

     $Header = Get-Header -scope "portal" -Tenant "disney.com" -Username "Donald@disney.com" -Password "Mickey01" 
     $Header = Get-Header -scope "graph" -Tenant "disney.com" -AppId "aa73b052-6cea-4f17-b54b-6a536be5c832" -Thumbprint "B35E2C978F83B49C36611802DC08B7DF7B58AB08" 
     $Header = Get-Header -scope "azure" -Tenant "disney.com" -AppId "aa73b052-6cea-4f17-b54b-6a536be5c715" -Secret 'xznhW@w/.Yz14[vC0XbNzDFwiRRxUtZ3'
     $Header = Get-Header -scope "azure" -Tenant "disney.com" -Interactive

### General Usage:

Use the interactive switch for gaining an OIDC token for use with Azure.

`$Header = Get-Header -scope "azure" -Tenant "disney.com" -Interactive`

This module supports multiple authentication flows.

| Authentication flow | Description                                      |
| ------------------- | ------------------------------------------------ |
| authorization_code  | Interactive OIDC authentication                  |
| client_credentials  | Certificate based authentication                 |
| client_credentials  | Application Registration with Key authentication |
| password            | username and passsword based authentication      |

Example - Using a header with an http get request

```powershell
 $Tenant                = 'laurierhodes.info'
 $AppId                 = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
 $secret                = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
 $header = Get-Header -Tenant $Tenant -AppId $appid -secret $secret -Scope azure

  $uri = "https://management.azure.com/subscriptions/$($subscriptionId)/resourcegroups/$($resourceGroup)/providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)?api-version=2020-08-01"

  $result = Invoke-RestMethod -Uri $uri -Method GET -Header $header 

  $WorkspaceId = $result.properties.customerId
```