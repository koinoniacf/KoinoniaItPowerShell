<#PSScriptInfo
.VERSION 1.0.0
.GUID 9f443ca7-e536-40ee-a774-7d94c5d3c569

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.DESCRIPTION
This will return random characters.

.PARAMETER Lenght
The number of characters to return.

.PARAMETER Characters
A string of characters to use.
#>
param (
  [ValidateRange(1, [int]::MaxValue)][int]$Length = 1,
  $Characters = "abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!@#$%^&*()_+-=[]\{}|;:,./<>?"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
$Random = 1..$Length | ForEach-Object { Get-Random -Maximum $Characters.length }
$private:ofs = ""
return [String]$Characters[$Random]

