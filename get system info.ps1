# Type in a PowerShell script here
# and finish it by either get- cmdlet or write-output
CLS
$cname = Read-Host "Enter Machine Name or IP Address"
Systeminfo /S $cname | Format-Table -AutoSize Write-Host



