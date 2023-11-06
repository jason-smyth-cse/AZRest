# AZRest

Powershell Module for authenticating and working with Azure (and other Microsoft cloud) services using REST (no dll dependency).

Not using developer kit modules or powershell cmdlets removes the prospect of "dll hell" or issues with conflicting cmdlets.  I've found that managing Azure with REST is much easier and more reliable than using cmdlets.

## Download And Import

Either, download all the files into your PowerShell module path (usually C:\Program Files\WindowsPowerShell\Modules) and import it...

```powershell
Import-Module -Name 'AZRest'
```

or, download or clone the module files and dynamically import the module from that file location:

```powershell
 Import-Module "C:\Users\Laurie\Documents\GitHub\AZRest\AZRest.psm1" 
```