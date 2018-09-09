$computername = Read-Host "Enter Machine Name or IP address"  
Get-WmiObject Win32_ComputerSystem -ComputerName $computername | Select-Object -ExpandProperty UserName