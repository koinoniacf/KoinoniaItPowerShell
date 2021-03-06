<#PSScriptInfo
.VERSION 1.0.0
.GUID 5e42fd43-6940-434e-bb1c-aebb8ac32e44

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.DESCRIPTION
This script will clear the AdminAcount for all user who have it set.

.LINK
https://docs.microsoft.com/en-us/windows/win32/adschema/a-admincount
#>
Get-ADUser -Filter { AdminCount -ne "0" } -Properties AdminCount | Set-ADUser -Clear AdminCount

