<#PSScriptInfo
.VERSION 1.0.0
.GUID d96e4855-2468-4294-8475-4b954ad009dd

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.SYNOPSIS
This will test is the we are running as an addministrator.

.DESCRIPTION
This will test is the we are running as an addministrator. If will return True or False.

.PARAMETER Message
The message that will be shown to the user. The message is only shown when -Warn or -Throw are specified.

.PARAMETER Warn
The script will present a waiting if not running as an admin.

.PARAMETER Thow
The script will throw if not running as an admin.

.EXAMPLE
Test-Admin
False
#>
param (
  [string]$Message = "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!",
  [switch]$Warn,
  [switch]$Throw
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { return $true }
else {
  If ($Warn) { Write-Warning $Message }
  If ($Throw) { Throw $Message }
  return $false
}
