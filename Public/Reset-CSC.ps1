<#PSScriptInfo
.VERSION 1.0.0
.GUID a4176bef-cf00-42a8-b097-8c9be952931c

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.DESCRIPTION
This will reset the CSC (offline files) cache.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param ()
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\CSC\Parameters\ -Name FormatDatabase -Value 1 -Type DWord
