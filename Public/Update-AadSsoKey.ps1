<#PSScriptInfo
.VERSION 1.0.0
.GUID 324df81c-9595-4025-b826-08aff404f533

.DESCRIPTION
This script will preform a roll over of Azure SSO Kerberos key. Run this script on the server running Azure AD Connect.

.AUTHOR
Jason Cook, Wybe Smits
http://www.wybesmits.nl

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
.RELEASENOTES
    * 1.0 - initial release 15/04/2019
#>

<#
.SYNOPSIS
This script will preform a roll over of Azure SSO Kerberos key. Run this script on the server running Azure AD Connect.

.LINK
https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sso-faq#how-can-i-roll-over-the-kerberos-decryption-key-of-the-azureadssoacc-computer-account
#>
Import-Module $Env:ProgramFiles'\Microsoft Azure Active Directory Connect\AzureADSSO.psd1d'
New-AzureADSSOAuthenticationContext #Office 365 Global Admin
Update-AzureADSSOForest -OnPremCredentials (Get-Credential -Message "Enter Domain Admin credentials" -UserName ($env:USERDOMAIN + "\" + $env:USERNAME))

