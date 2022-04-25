<#PSScriptInfo
.VERSION 1.0.0
.GUID 3642a129-3370-44a1-94ad-85fb88de7a6b

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.DESCRIPTION
This will continue if the spesified key it press. Otherwise, it will break.

.PARAMETER Key
The key that this will listen for.

.EXAMPLE
Wait-ForKey -Key c
Press c to continue, any other key to abort.: c
#>
param(
    [string]$Key = "y",
    [string]$Message = "Press $Key to continue, any other key to abort."
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Response = Read-Host $Message
If ($Response -ne $Key) { Break }
