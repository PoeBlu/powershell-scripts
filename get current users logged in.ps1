$computername = 'al1d38578'

Get-WMIObject Win32_Process -filter 'name="explorer.exe"' -computername $ComputerName |
	ForEach-Object { $owner = $_.GetOwner(); '{0}\{1}' -f $owner.Domain, $owner.User } |
	Sort-Object | Get-Unique