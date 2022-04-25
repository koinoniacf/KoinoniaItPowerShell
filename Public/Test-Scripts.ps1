<#PSScriptInfo
.VERSION 1.0.0
.GUID dd50132f-8bc5-4825-918d-9fd0afd3f36b

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.DESCRIPTION
Used to test LoadDefaults and ensure defaults parameters are being loaded correctly.
#>
Param(
    [string]$foo,
    [string]$bar = "bar",
    [string]$baz = "bazziest"
)
$MyInvocation
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
# . (I:\Applications\Powershell\KoinoniaIt\Private\LoadDefaults.ps1 -Invocation $MyInvocation) -Invocation $MyInvocation

Write-Output "params"
write-output "foo: $foo"
write-output "bar: $bar"
write-output "baz: $baz"
write-output "test: $test"

