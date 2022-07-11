<#PSScriptInfo

.VERSION 1.0.2

.GUID 7e41b659-a682-489a-830d-5a118f2e11be

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

#> 

<#
.DESCRIPTION
Enable permission interitance for the specified users.

.PARAMETER Users
An array of users to enable inheritence for.

.PARAMETER Protected
Set to $false to enable inheritance or $true to disable inheritance. Default is $false.

.PARAMETER preserveInheritance
Set to $true to keep inherited access rules or $false to remove inherited access rules. Ignored if Protected is $false. Default is $true.

.LINK
https://itomation.ca/enable-ad-object-inheritance-using-powershell/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param (
    $Users,
    $Protected = $false,
    $Preserve = $true
)

Test-Admin -Warn -Message "You likely need to must be an administrator to change permissions." | Out-Null

$Users | ForEach-Object {
    $DistinguishedName = [ADSI]("LDAP://" + $_)
    $Acl = $DistinguishedName.psbase.objectSecurity
    [PSCustomObject]$Results = @{
        SamAccountName    = $_.SamAccountName
        DistinguishedName = $_.DistinguishedName
        Inheritence       = $Acl.get_AreAccessRulesProtected()
        Changed           = $null
    }
    if ($Acl.get_AreAccessRulesProtected()) {
        If ($PSCmdlet.ShouldProcess($_.SamAccountName, "Enable-AdUserPermissionInheritance.ps1")) {
            $Acl.SetAccessRuleProtection($Protected, $Preserve)
            $DistinguishedName.psbase.commitchanges()
            $Results.Changed = $true
            return [PSCustomObject]$Results
        }
        elseif ( $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent ) { return [PSCustomObject]$Results }
    }
    elseif ( $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent ) { return [PSCustomObject]$Results }
}
