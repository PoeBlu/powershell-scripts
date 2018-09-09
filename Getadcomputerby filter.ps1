Get-ADComputer -LDAPFilter "(name=*Al1*)" -SearchBase "OU=Servers,OU=Corp,DC=Endo,DC=com" | Select-Object Name,Description,DisplayName,Status | Out-file H:\Al1lservers.csv
