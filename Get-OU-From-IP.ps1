# Author : Assaf Miron
# Http://assaf.miron.googlepages.com
# Description :
# 			This Script outputs to a file the OU location of computer IP's from a List text file
#			Using the Ping-Host command from PSCX
# Input : IP List text File and a Path to a log file
# Output: Log file that has the Canonical Names of all Computers in the IP List Text File
param ($IPFile = $(Read-Host "al1l59545.endo.com"),$LogFile = $(Read-Host "D:\"))

$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
IF( Get-PSSnapin | where { $_.Name -eq "PSCX" } ) {
	$msg = "Script Has Started $(Get-Date)" + "`n`r`n" + "Reading from File $IPFile`n`r`n"
	Out-File $logFile -InputObject $msg 
	$File = Get-Content $IPFile
	
	ForEach ( $line in $File){
		# Resolve the computer name using ping
		$tmpHost = (Ping $line).Host.Split(".")[0]
		# GetCanonical Name from VBS
		$tmpOU = Invoke-Expression ("Cscript -nologo $ScriptLocation\SearchObjects-ReturnCanonicalName.vbs $tmpHost computer") 
		# Output to the Log file
		$line+","+$tmpOU | Out-File -Append $LogFile
	}
}
