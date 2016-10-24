Function Invoke-Function1 {
<#
.SYNOPSIS
Execute Function1

.DESCRIPTION
This is a description for a cmdlet called Invoke-Function1

.EXAMPLE
Invoke-Function1 -Parameter1 Hello

.EXAMPLE
Invoke-Function1 [CommondParameters]



.NOTES
Author   : Raymond Velasquez
Email    : at.supermamon@gmail.com
Created  : 2016-10-21
Updated  : Never
Changelog:

#>
  [CmdletBinding()]
  param()


  Write-Output "Function1"
    
}