<#PSScriptInfo

.VERSION 1.0.1

.GUID 10ba8c03-4333-4f67-b11b-b25fef85943b

.AUTHOR Jason Cook

.COMPANYNAME Koinonia Christian Fellowship

.COPYRIGHT Copyright (c) Koinonia Christian Fellowship 2022

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#> 

<#
.DESCRIPTION
Install module if not pressent.
#>
param($Name, $AltName)
Write-Verbose "$me Installing $Name Module if missing"
If (!(Get-Module -ListAvailable -Name $Name)) {
	Install-Module $Name
}
