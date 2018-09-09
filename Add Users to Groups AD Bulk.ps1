Import-Module ActiveDirectory
$GroupName = "LIQUIDS MASTER Production BPR's (MFG-PKG)_Read"
$Users = Import-Csv -Delimiter ";" -Path "H:\ADUsers.csv" 
foreach ($User in $Users) { Add-ADGroupMember $GroupName $User }