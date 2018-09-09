Import-Csv '.\Employees.csv' | foreach {Set-ADAccountExpiration -identity $_.username -Date
Time $_.EndDate}