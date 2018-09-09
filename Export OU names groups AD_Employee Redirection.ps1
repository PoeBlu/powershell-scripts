$users = (Get-ADUser -Filter * -SearchBase 'OU=Employee Redirection Migration,OU=Employees,OU=Endo Users,OU=Corp,DC=Endo,DC=com' | 
Select-Object Name,SamAccountName﻿)

# Export-Csv 'c:\Users\Jaime.Denys\Desktop\Employee Redirection Migration.csv' -notypeinformation