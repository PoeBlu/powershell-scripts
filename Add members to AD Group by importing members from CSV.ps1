Import-Module ActiveDirectory
  $adGroup = "APPSEC_TrackSafe_HSVL18_SUP"
Import-Csv "H:\UsersGroups.csv" | ForEach-Object {
 $samAccountName = $_."samAccountName"
 Add-ADGroupMember $adGroup $samAccountName;
 Write-Host "- "$samAccountName" added to "$adGroup
}