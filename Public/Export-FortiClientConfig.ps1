<#PSScriptInfo

.VERSION 1.2.4

.GUID 6604b9e8-5c58-4524-b094-07b549c2dad8

.AUTHOR Jason Cook

.COMPANYNAME Dennis Group

.COPYRIGHT Copyright (c) Dennis Group 2022

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
<#
.DESCRIPTION
This will export the current Forti Client configuration.

.PARAMETER Path
The location the configuration will be exported to.

.EXAMPLE 
Export-FortiClientConfig -Path backup.conf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    $Path = "backup.conf",
    [ValidateScript( { Test-Path -Path $_ })]$FCConfig = 'C:\Program Files\Fortinet\FortiClient\FCConfig.exe',
    $Password
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Arguments = ("-m all", ("-f " + $Path), "-o export", "-i 1")
if ($Password) { $Arguments += "-p $Password" }

if ($PSCmdlet.ShouldProcess($Path, "Export FortiClient Config")) {
    Start-Process -FilePath $FCConfig -ArgumentList $Arguments -NoNewWindow -Wait    
}

if ($PSCmdlet.ShouldProcess($Path, "Export FortiClient Config")) {
    Start-Process -FilePath $FCConfig -ArgumentList $Arguments -NoNewWindow -Wait    
}

