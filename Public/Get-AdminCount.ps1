<#PSScriptInfo
.VERSION 1.0.0
.GUID 11e3b42b-44ff-41e2-b70d-2ec61685f52f

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.DESCRIPTION
This script will list all users with the AdminAcount attribute set.

.LINK
https://docs.microsoft.com/en-us/windows/win32/adschema/a-admincount
#>
Get-ADUser -Filter { AdminCount -ne "0" } -Properties AdminCount | Select-Object name, AdminCount

