<#PSScriptInfo
.VERSION 1.1.1
.GUID 674855a4-1cd1-43b7-8e41-fea3bc501f61

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.SYNOPSIS
This commands checks the Bitlocker status and returns it in a human readable format.

.DESCRIPTION
This commands checks the Bitlocker status and returns it in a human readable format.

.PARAMETER Drive
The drive to check for protection on. If unspesified, the System Drive will be used.
#>
param (
  [ValidateScript( { Test-Path $_ })][string]$Drive = $env:SystemDrive
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

If (!(Test-Path $Drive)) {
  Write-Error "$Drive is not valid. Please choose a valid path."
  Break
}

switch ((Get-WmiObject -Namespace ROOT\CIMV2\Security\Microsoftvolumeencryption -Class Win32_encryptablevolume -Filter "DriveLetter = `'$( Split-Path -Path $Drive -Qualifier)`'" -ErrorAction Stop).protectionStatus) {
  ("0") { $protectans = "Unprotected" }
  ("1") { $protectans = "Protected" }
  ("2") { $protectans = "Unknown" }
  default { $protectans = "NoReturn" }
}
$protectans
