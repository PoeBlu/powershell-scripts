Import-module ActiveDirectory 
Import-CSV "C:\users\jaime.denys\desktop\users.csv" | % { 
Add-ADGroupMember -Identity "QADocControlLiquidsMasterProductionBPRS_Read" -Member $_.UserName 
} 