Get-ADUser -Filter { AdminCount -ne "0" } -Properties AdminCount | Set-ADUser -Clear AdminCount
