Get-ADUser -Identity jaime.denys -Properties memberof |
Select-Object -ExpandProperty memberof