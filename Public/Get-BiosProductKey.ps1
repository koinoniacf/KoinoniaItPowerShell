<#PSScriptInfo
.VERSION 1.0.0
.GUID 8ccdb627-b33f-4be2-b6e0-f9cb992ee398

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
.DESCRIPTION
Return the product key stored in the UEFI bios.
#>
return (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey

