<#PSScriptInfo

.VERSION 1.0.2

.GUID 983e1108-74f9-41a5-8de9-f12145fbeffc

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
This will remove and reinstall OneDrive.
#>
Write-Verbose "Uninstalling OneDrive..."
Start-Process -FilePath C:\Windows\SysWOW64\OneDriveSetup.exe -NoNewWindow -Wait -Args "/uninstall"
Write-Verbose "Installing OneDrive..."
Start-Process -FilePath C:\Windows\SysWOW64\OneDriveSetup.exe -NoNewWindow
