### Function:  Get-JSONfile

### Purpose:

Transforms a saved JSON file to a Powershell Hash table

### Parameters:

-Path      = The file path for the json file to import.

### Example:

```powershell
 $object = Get-JSONfile `-Path "C:\templates\vmachine.json"
```

### General Usage:

This module is used to take Azure objects that have been backed up to file and transform them back into PowerShell objects that may be parsed or redeployed.