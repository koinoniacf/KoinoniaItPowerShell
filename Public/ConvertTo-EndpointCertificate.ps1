<#PSScriptInfo
.VERSION 1.1.1
.GUID c3469cd9-dc7e-4a56-88f2-d896c9baeb21

.AUTHOR
Jason Cook

.COMPANYNAME
Koinonia Christian Fellowship

.COPYRIGHT
Copyright (c) Koinonia Christian Fellowship 2022
#>

<#
    .SYNOPSIS
    This script will convert a PFX certificate for use with various services.

    .DESCRIPTION
    This script will convert a PFX certificate for use with various services. If will also provide instructions for any system that has spesific requirements for setup. This script requires & .\openssl.exe  to be available on the computer.

    .PARAMETER Path
    This is the certificate file which will be converted. This option is required. 

    .PARAMETER Prefix
    This string appears before the filename for each converted certificate. If unspesified, will use the name if the file being resized.
  #>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
  [string]$LocalPrefix,
  [string]$Suffix,
  [string]$Filter = "*.pfx"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$count = 1; $PercentComplete = 0;
$Certificates = Get-ChildItem -File -Path $Path -Filter $Filter
ForEach ($Certificate in $Certificates) {
  #Progress message
  $ActivityMessage = "Converting Certificates. Please wait..."
  $StatusMessage = ("Processing {0} of {1}: {2}" -f $count, @($Certificates).count, $Certificate.Name)
  $PercentComplete = ($count / @($Certificates).count * 100)
  Write-Progress -Activity $ActivityMessage -Status $StatusMessage -PercentComplete $PercentComplete
  $count++

  $Password = Read-Host "Enter Password"
  If ($PSCmdlet.ShouldProcess("$OutName", "Convert-Certificate")) {  
    $LocalPrefix = $Prefix + [System.IO.Path]::GetFileNameWithoutExtension($Certificate.FullName) + "_"
    $Path = $Certificate.FullName
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -out "$LocalPrefix`PEM.txt" -nodes 
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nocerts -out "$LocalPrefix`PEM_Key.txt" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$LocalPrefix`PEM_Cert.txt" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$LocalPrefix`PEM_Cert_NoNodes.txt"
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$LocalPrefix`PEM_Cert.cer" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -export -in "$LocalPrefix`PEM_Cert.txt" -inkey "$LocalPrefix`PEM_Key.txt" -certfile "$LocalPrefix`PEM_Cert.txt" -out "$LocalPrefix`Unifi.p12" -name unifi -password pass:aircontrolenterprise
        
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nocerts -nodes | openssl.exe  rsa -out "$LocalPrefix`RSA_Key.txt"
    openssl.exe rsa  -passin "pass:$Password" -in "$LocalPrefix`PEM.txt" -pubout -out "$LocalPrefix`RSA_Pub.txt"
    Write-Output ""

    Write-Output "To import to Windows run the following commands.`n`$mypwd = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'`nImport-PfxCertificate -FilePath C:\Local\Web.pfx -CertStoreLocation Cert:\LocalMachine\My -Password `$mypwd.Password`n"

    New-Item -Force -Type Directory -Name AlwaysUp | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" AlwaysUp\ctc-self-signed-certificate-exp-2024.pem
    Copy-Item "$LocalPrefix`PEM_Key.txt" AlwaysUp\ctc-self-signed-certificate-exp-2024-key.pem
    Write-Output "Always Up: Copy files to C:\Program Files (x86)\AlwaysUpWebService\certificates`n"

    New-Item -Force -Type Directory -Name CiscoSG300 | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" CiscoSG300\Cert.txt
    Copy-Item "$LocalPrefix`RSA_Pub.txt" CiscoSG300\RSA_Pub.txt
    Copy-Item "$LocalPrefix`RSA_Key.txt" CiscoSG300\RSA_Key.txt
    Write-Output "Cisco SG300: Use RSA Key, RSA Pub, and PEM Cert`nFor RSA Pub, remove the first 32 characters and change BEGIN/END PUBLIC KEY to BEGIN/END RSA PUBLIC KEY. Use only the primary certificate, not the entire chain. When importing, edit HTML to allow more than 2046 characters in certificate feild.`nInstructions from: https://severehalestorm.net/?p=54`n"

    New-Item -Force -Type Directory -Name PaperCutMobility | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" PaperCutMobility\tls.cer
    Copy-Item "$LocalPrefix`PEM_Key.txt" PaperCutMobility\tls.pem
    Write-Output "PaperCut Mobility: `n"

    New-Item -Force -Type Directory -Name Spiceworks | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" Spiceworks\ssl-cert.pem
    Copy-Item "$LocalPrefix`PEM_Key.txt" Spiceworks\ssl-private-key.pem
    Write-Output "Spiceworks: Copy files to C:\Program Files (x86)\Spiceworks\httpd\ssl`n"

    New-Item -Force -Type Directory -Name UnifiCloudKey | Out-Null
    Write-Verbose "Instructions from here: https://community.ubnt.com/t5/UniFi-Wireless/HOWTO-Install-Signed-SSL-Certificate-on-Cloudkey-and-use-for/td-p/1977049"
    Write-Output "Unifi Cloud Key: Copy files to '/etc/ssl/private' on the Cloud Key and run the following commands.`ncd /etc/ssl/private`nkeytool -importkeystore -srckeystore unifi.p12 -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -destkeystore unifi.keystore.jks -storepass aircontrolenterprise`nkeytool -list -v -keystore unifi.keystore.jks`ntar cf cert.tar cloudkey.crt cloudkey.key unifi.keystore.jks`ntar tvf cert.tar`nchown root:ssl-cert cloudkey.crt cloudkey.key unifi.keystore.jks cert.tar`nchmod 640 cloudkey.crt cloudkey.key unifi.keystore.jks cert.tar`nnginx -t`n/etc/init.d/nginx restart; /etc/init.d/unifi restart`n"
    Copy-Item "$LocalPrefix`PEM_Cert.txt" UnifiCloudKey\cloudkey.crt
    Copy-Item "$LocalPrefix`PEM_Key.txt" UnifiCloudKey\cloudkey.key
    Copy-Item "$LocalPrefix``unifi.p12" UnifiCloudKey\unifi.p12

    New-Item -Force -Type Directory -Name UnifiCore | Out-Null
    Write-Output "Unifi Cloud Key: Copy files to '/data/unifi-core/config' on the Cloud Key and run the following commands.`n`nsystemctl restart unifi-core.service`n"
    Copy-Item "$LocalPrefix`PEM_Cert_NoNodes.txt" UnifiCore\unifi-core.crt
    Copy-Item "$LocalPrefix`RSA_Key.txt" UnifiCore\unifi-core.key

    New-Item -Force -Type Directory -Name USG | Out-Null
    Copy-Item "$LocalPrefix`PEM.txt" server.pem
    Write-Output "Edge Router or USG: Copy the PEM file to '/etc/lighttpd/server.pem' and run the following commands."
    Write-Output "kill -SIGINT `$(cat /var/run/lighttpd.pid)"
    Write-Output "/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf"
    Write-Output ""

    Write-Output "IIS Management: Add PFX certificate to server and run the following commanges in Powershell"
    Write-Output "`$mypwd = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'>"
    Write-Output "Import-PfxCertificate -FilePath '.\Koinonia Christian Fellowship Web.pfx' -CertStoreLocation Cert:\LocalMachine\My -Password `$mypwd.Password"
    Write-Output "`$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {`$_.subject -like `"*Koinonia Christian Fellowship*`"} | Where-Object {`$_.NotAfter -gt (Get-Date)} | Select-Object -ExpandProperty Thumbprint"
    Write-Output "Import-Module WebAdministration"
    Write-Output "Remove-Item -Path IIS:\SslBindings\0.0.0.0!8172"
    Write-Output "Get-Item -Path `"cert:\localmachine\my\`$cert`" | New-Item -Force -Path IIS:\SslBindings\0.0.0.0!8172"
    Write-Output "https://support.microsoft.com/en-us/help/3206898/enabling-iis-manager-and-web-deploy-after-disabling-ssl3-and-tls-1-0"
    Write-Output ""

    <#
          RSA
          RSA SG300
          RSA Pub
          pfx
          PEM
          p7b
          DER
          B64
          B64 Chain
          #>
  }
}

