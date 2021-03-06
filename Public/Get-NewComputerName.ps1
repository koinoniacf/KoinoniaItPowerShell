<#PSScriptInfo

.VERSION 1.0.3

.GUID f0c0a88c-be5c-46ee-ab03-86272a36b5d7

.AUTHOR Jason Cook

.COMPANYNAME The Dennis Group

.COPYRIGHT Copyright (c) Dennis Group 2022

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
This script will rename the computer based on the prefix and serial number.

.PARAMETER Prefix
The prefix to use for the computer name.

.PARAMETER Serial
The serial nubmer to use for the computer name.

.PARAMETER PrefixLenght
The lenght of the prefix. This is used to truncate the prefix so the total length is less than 15 characters.

.PARAMETER NewName
The new name to use for the computer.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Password")]
param (
    [string]$Prefix,
    [string]$Serial = (Get-WmiObject win32_bios).Serialnumber,
    $PrefixLenght = ($(15 - $Serial.length), $Prefix.Length | Measure-Object -Minimum ).Minimum
)

return $Prefix.Substring(0, $PrefixLenght) + $Serial
