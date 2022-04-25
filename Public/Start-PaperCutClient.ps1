<#PSScriptInfo
.VERSION 1.0.0
.GUID 090b7063-ddf4-4e5f-91ab-24127dec0d57

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.SYNOPSIS
This script will run the PaperCut client.

.DESCRIPTION
This script will run the PaperCut client. It will first check the network location and fall back to the local cache is that fails.

.PARAMETER SearchLocations
Specifies the folders to search for the client in.

.EXAMPLE
Start-PaperCutClient

.EXAMPLE
Start-PaperCutClient -SearchLocations "\\print\PCClient\win","C:\Cache"
#>
param (
  [string[]]$SearchLocations = @("\\print\PCClient\win", "C:\Cache")
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$SearchLocations | ForEach-Object {
  Write-Verbose "Searching in $_"
  $NetworkPath = $_ + "\pc-client-local-cache.exe"
  If (Test-Path -PathType Leaf -Path $NetworkPath) {
    Write-Verbose "Found network file at $NetworkPath"
    Get-Process -Name pc-client -ErrorAction SilentlyContinue | Stop-Process
    Start-Process -FilePath $NetworkPath -ArgumentList "--silent"
    Break
  }
  $LocalPath = (Get-ChildItem -Path $_ -Filter "pc-client.exe*" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1).FullName + "\pc-client.exe"
  If (Test-Path -PathType Leaf -Path $LocalPath) {
    Write-Verbose "Found local file at $LocalPath"
    Get-Process -Name pc-client -ErrorAction SilentlyContinue | Stop-Process
    Start-Process -FilePath $LocalPath -ArgumentList "--silent"
  }
}
