Get-ADUser -Filter * -SearchBase 'OU=Employees,OU=Employee Redirection Migration,OU=Endo Users,OU=Corp,DC=Endo,DC=com' | 
Select-Object Name,SamAccountName﻿  | 
Export-Csv 'c:\Users\Jaime.Denys\Desktop\Employee Redirection Migration.csv'