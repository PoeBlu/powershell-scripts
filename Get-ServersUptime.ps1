<#

	.Synopsis 
        Query Uptime Details of servers.
        
    .Description
        This script helps you to get the uptime details of the servers. It also generates a HTML report
		when -HTMLReport switch is used. The report contains the uptime details and a summary of how many
		computers reachable and how many are not
 
    .Parameter ComputerName    
        Computer name(s) for which you want to get the uptime details.
	
	.Parameter HTMLReport
		Generates a HTML report in c:\ drive with name uptimereport.html by default. You can override this by
		specifying -HTMLFile parameter
	
	.Parameter HTMLFile
		Name of the file path where you want to store the report
        
    .Example
        Get-UptimeOfServers.ps1 -ComputerName Comp1, Comp2
		
		Gets the Uptime of Comp1 and Comp2
    .Example
        Get-UptimeOfServers.ps1 -ComputerName Comp1, Comp2 -HTMLReport
        
		Get the uptime of Comp1 and Comp2 and saves the report in HTML format
		
	.Example
        Get-Content c:\servers.txt | Get-UptimeOfServers.ps1 -HTMLReport
        
		Get the uptime of computers listed in servers.txt and saves the report in HTML format	
       
    .Notes
        NAME:      Get-UptimeOfServers.ps1
        AUTHOR:    Sitaram Pamarthi
		WEBSITE:   http://techibee.com

#>

[cmdletbinding()]

param(
	[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
	[string[]]$ComputerName = $env:computername,
	[switch]$HTMLReport,
	[string]$HTMLFile = "H:\Uptimereport.html"
)

begin{
if($HTMLReport) {
	$Report = "
			<html>
				<head>
					<title> Server Uptime Report </title>
				</head>
				<body>
					<H1 Align=`"Center`"> <B>Server Uptime Report </B></H1>
					<br>
					<H3 Align=`"Center`"> Report Generated at $(Get-Date)</H3>
					<table BORDER=`"1`" CELLPADDING=`"5`" Align=`"Center`">
					<tr>
						<td BGColor=Yellow Align=center><b>S. No</b></td>
						<td BGColor=Yellow Align=center><b>Server Name</b></td>
						<td BGColor=Yellow Align=center><b>IsOnline</b></td>
						<td BGColor=Yellow Align=center><b>Status</b></td>
					</tr>"
 
}
}
process {
	$Count=0
	$SuccessComps = 0
	$UnreachableComps = 0
	$FailedComps = 0
	$FinalOutput = @()
	foreach($Computer in $ComputerName) {
		$Count++
		$Computer = $Computer.Toupper()
		$OutputObj	= New-Object -TypeName PSobject
		$OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer
		$Status = 0
		if(Test-Connection -Computer $Computer -count 1 -ea 0) {
			$OutputObj | Add-Member -MemberType NoteProperty -Name IsOnline -Value "TRUE"
			try {
				$Boottime = (Get-WmiObject win32_operatingSystem -computer $Computer -ErrorAction stop).lastbootuptime
				$Boottime = [System.Management.ManagementDateTimeconverter]::ToDateTime($BootTIme)
				$Now = Get-Date
				$span = New-TimeSpan $BootTime $Now 
				$Uptime = "{0} day(s), {1} hour(s), {2} min(s), {3} second(s)" -f $span.days, $span.hours, $span.minutes, $span.seconds
				$OutputObj | Add-Member -MemberType NoteProperty -Name Uptime -Value $Uptime
				$Status=1
				$SuccessComps++
			} catch {
				$OutputObj | Add-Member -MemberType NoteProperty -Name Uptime -Value "FAILED TO GET"
				$FailedComps++
			}

		} else {
			$OutputObj | Add-Member -MemberType NoteProperty -Name IsOnline -Value "FALSE"
			$OutputObj | Add-Member -MemberType NoteProperty -Name Uptime -Value ""
			$UnreachableComps++
		}
		
		$FinalOutput +=$OutputObj
		
		if($HTMLReport) {
			if($Status) {
				$BGColor="green"
			} else {
				$BGColor="red"
			}
			$Report += "<TR>
						<TD BGColor=$BGColor>$Count</TD>
						<TD BGColor=$BGColor>$($OutputObj.ComputerName)</TD>
						<TD BGColor=$BGColor>$($OutputObj.IsOnline)</TD>
						<TD BGColor=$BGColor>$($OutputObj.Uptime)</TD>
						</TR>"
				
		} else {
			$OutputObj
		}
	
	}
	
	
}
end{
	if($HTMLReport) {
		$Report +="</table>
				<br>
				<h3>Report Summary:</h3>
				<table>
				<tr>
					<td>Total No. of Computers scanned</td>
					<td>: $Count</td>
				</tr>
				<tr>
				<td>No. Of computers online</td>
				<td>: $SuccessComps</td>
			 </tr>
			  <tr>
				<td>No. Of computers Offline</td>
				<td>: $UnreachableComps</td>
			 </tr>
			 <tr>
				<td>No. Of computers Failed to query</td>
				<td>: $FailedComps</td>
			 </tr>
			 </table>
			<h5><font color=`"brown`">This report is brought to you by 
			<a href=`"http://techibee.com`">http://techibee.com</a> `(<a href=`"https://twitter.com/pamarths`">Follow</a>`). 
			Visit for more Powershell scripts and System administrator Material</font></h5>
	</body>
	</html>
				"			
		$Report | Out-File $HTMLFile -Force
	}
}