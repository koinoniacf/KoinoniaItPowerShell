<#PSScriptInfo
.VERSION 1.0.1
.GUID 4ec63b79-6484-43eb-90f8-bef7e2642564

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.DESCRIPTION
This script will find all orphaned GPOs.

.LINK
https://4sysops.com/archives/find-orphaned-active-directory-gpos-in-the-sysvol-share-with-powershell/
#>

[CmdletBinding()]
param (
    [string]$ForestName = (Get-ADForest).Name,
    $Domains = (Get-AdForest -Identity $ForestName | Select-Object -ExpandProperty Domains)
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

try {
    ## Find all domains in the forest
    

    $gpoGuids = @()
    $sysvolGuids = @()
    foreach ($domain in $Domains) {
        $gpoGuids += Get-GPO -All -Domain $domain | Select-Object @{ n = 'GUID'; e = { $_.Id.ToString() } } | Select-Object -ExpandProperty GUID
        foreach ($guid in $gpoGuids) {
            $polPath = "\\$domain\SYSVOL\$domain\Policies"
            $polFolders = Get-ChildItem $polPath -Exclude 'PolicyDefinitions' | Select-Object -ExpandProperty name
            foreach ($folder in $polFolders) {
                $sysvolGuids += $folder -replace '{|}'
            }
        }
    }

    Compare-Object -ReferenceObject $sysvolGuids -DifferenceObject $gpoGuids | Select-Object -ExpandProperty InputObject
}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}
