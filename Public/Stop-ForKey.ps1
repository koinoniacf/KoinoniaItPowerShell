<#PSScriptInfo
.VERSION 1.0.0
.GUID 9b9dfb07-a7ea-4afd-94ab-74a5bf2ee340

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.SYNOPSIS
This will break if the spesified key it press. Otherwise, it will continue.

.DESCRIPTION
This script will run the PaperCut client. It will first check the network location and fall back to the local cache is that fails.

.PARAMETER Key
The key that this will listen for.

.EXAMPLE
Stop-ForKey -Key q
Press q to abort, any other key to continue.: q
#>
param (
  $Key
)
$Response = Read-Host "Press $Key to abort, any other key to continue."
If ($Response -eq $Key) { Break }

