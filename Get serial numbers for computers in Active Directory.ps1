# Requires ActiveRoles CmdLets from Quest Software (They're free and awesome) - http://www.quest.com/powershell/activeroles-server.aspx
Get-QADComputer -searchroot "OU=Qualitest Computers,OU=Client Workstations,OU=Corp,DC=Endo,DC=com" -SizeLimit 0 |
ForEach-Object {
  $hostname = $_.name
  $serialnumber = (Get-WMIObject Win32_BIOS -computer $hostname -ErrorAction SilentlyContinue).SerialNumber
  if (-not $serialnumber) {
    Add-Content H:\logfiles\offlinehosts.txt "$hostname is in offline"
  }
  else {
  Write-Host "$hostname,$serialnumber" # output to screen 
  Add-Content H:\logfiles\serialnumberlist.txt "$hostname,$serialnumber"
  }
}