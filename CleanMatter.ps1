$Res = Get-Content "CheckMe.txt" | Where-Object {$_.Contains("Target")}
$CT = $Res.Trim()
$CT = $CT.Substring(8)
$CT.Trim() | Out-File "Result.txt"
Remove-Item -Path "CheckMe.txt" -Force
New-Item "RunThis.cmd" -Type File -Force -Value "@Echo Off" | Out-Null
Add-Content "RunThis.cmd" "`n"
$ReadLine = Get-Content "Result.txt"
ForEach ($Line In $ReadLine) {
	Add-Content "RunThis.cmd" "cmdkey /Delete:$Line"
}
Add-Content "RunThis.cmd" "net use * /DEL"
Add-Content "RunThis.cmd" "cmdkey /Delete:WindowsLive:target=virtualapp/didlogical"
Add-Content "RunThis.cmd" "cmdkey /Delete:$Env:ComputerName"
Add-Content "RunThis.cmd" "cmdkey /Delete /ras"
Remove-Item -Path "CheckMe.cmd" -Force
Remove-Item -Path "Result.txt" -Force
