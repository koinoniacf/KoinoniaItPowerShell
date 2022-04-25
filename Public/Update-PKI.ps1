<#PSScriptInfo
.VERSION 1.0.0
.GUID 8f760b1c-0ccc-43b7-bfed-9370fa84b7f8

.DESCRIPTION
Upload CRLs to GitHub if changed.

.AUTHOR
Jason Cook

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
.COMPANYNAME
Koinonia Christian Fellowship

#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    $Path = "./",
    $AccessToken = "",
    $OwnerName = "",
    $RepositoryName = "",
    $BranchName = "",
    [switch]$Force
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
Get-ChildItem -Path $Path -Exclude *.sha256 | ForEach-Object {
    If ($PSCmdlet.ShouldProcess($_.Name, "Update-PKI")) {
        $NewHash = (Get-FileHash $_.FullName).Hash
        if ((Get-Content -Path ($_.FullName + ".sha256") -ErrorAction SilentlyContinue) -ne $NewHash -OR $Force) {
            Set-GitHubContent -OwnerName $OwnerName -RepositoryName $RepositoryName -BranchName $BranchName -AccessToken $AccessToken -CommitMessage ("Updating CRL from " + $env:computername) -Path  ("pki\" + $_.Name) -Content ([convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName)))
            $NewHash | Out-File -FilePath ($_.FullName + ".sha256")
        }
    }
}
