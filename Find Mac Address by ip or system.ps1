# Type in a PowerShell script here
# and finish it by either get- cmdlet or write-output
$mname = Read-Host "Enter Machine Name or IP"
Get-WmiObject Win32_NetworkAdapter -ComputerName $mname | Where-Object { $_.MacAddress } | 
Select-Object Name, MacAddress

