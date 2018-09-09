Get-ADUser -Filter * -SearchBase 'OU=Qualitest Employees,OU=Employees,OU=Endo Users,OU=Corp,DC=Endo,DC=com' | 
Select-Object Name,SamAccountName﻿  | 
Export-Csv 'c:\Users\Jaime.Denys\Desktop\Usernames.csv'