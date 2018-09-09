Get-ADUser -Identity Brophy.Katherine -Properties memberof |
Select-Object -ExpandProperty memberof |
Add-ADGroupMember -Members Toland.Anne