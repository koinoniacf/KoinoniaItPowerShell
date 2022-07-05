<#PSScriptInfo

.VERSION 1.0.1

.GUID 772c6454-68cf-42aa-89b9-dd6dc5939e1b

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
.SYNOPSIS
Add an email address to an existing Microsoft 365 group.

.DESCRIPTION
Add an email address to an existing Microsoft 365 group. You can also use this to set the primary address for the group.

.PARAMETER Identity
The identity of the group you wish to change.

.PARAMETER EmailAddress
The email address you whish to add.

.PARAMETER SetPrimary
If set, this will set the email adress you specified as the primary address for the group.

.EXAMPLE
Add-GroupEmail -Identity staff -EmailAddress staff@example.com
#>
param (
    [string]$Identity,
    [mailaddress]$EmailAddress,
    [switch]$SetPrimary
)

Set-UnifiedGroup -Identity $-Identity -EmailAddresses: @{Add = $EmailAddress }
If ($SetPrimary) { Set-UnifiedGroup -Identity $-Identity -PrimarySmtpAddress  $EmailAddress }
