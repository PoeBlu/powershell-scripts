Get-WmiObject -Class "win32_quickfixengineering" |
Select-Object -Property "Description", "HotfixID", 

@{Name="InstalledOn"; Expression={([DateTime]($_.InstalledOn)).ToLocalTime()}}

