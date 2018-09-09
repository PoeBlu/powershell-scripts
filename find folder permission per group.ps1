# Type in a PowerShell script here
# and finish it by either get- cmdlet or write-output
Set-QADPSSnapinSettings -DefaultSizeLimit 0
$gname = Read-Host "al130-fs-02"
Get-QADuser -MemberOf $gname | Select-Object name,type,description | Format-Table name,type,description
