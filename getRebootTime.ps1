<#
	.NOTES
	Name:   Gary L Jackson                
	Ver:	1.0
	Date:   30-Sep-2014
	VERSION HISTORY:
			1.0 30-Sep-2014
				--GLJ, Creation date
			2.0 30-Sep-2014
				--GLJ, Modified to output to Excel and format table
            3.0 01-Oct-2014
                --GLJ, Modified to query AD for Citrix servers by default
				--GLJ, Added check for AD module, if not found, install it
								
	.SYNOPSIS
	This utility is used get server reboot time
	.DESCRIPTION
	This utility is used get server reboot time by feeding in a list of servers. The script
    will use WMI, specifically the Win32_OperatingSystem class, to query for last bootup time
	
	.PARAMETER $Computername
	This parameter can be fed in via a text file

	.EXAMPLE
	get-content C:\temp\ctx_servers.txt | get-LastBootTime

    The above command will read in the text file and input each server name into the get-LastBootTime
    function and output to excel

    .EXAMPLE
    get-LastBootTime -computername acmeserver1, acmeserver2

    The above command will run the get-LastBootTime function against servers acmeserver1, acmeserver2
    and output to excel
    
    .EXAMPLE
    get-LastBootTime

    The above command will run the get-LastBootTime function against all Citrix Servers
    and output to excel

#>
function get-LastBootTime {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $False,
				   ValueFromPipeline = $True)]
		[string[]]$computername = $(Get-ADComputer -SearchBase "OU=Corp,DC=Endo,DC=com" -filter * |
		where { $_.Name -like 'ACMEV*' } | select -expand Name | Sort-Object $_)
	)
	
	BEGIN {
		# Stole this from Marc Carter. Thanks Marc!
		Try {
			if (-not (Get-Module -Name "ActiveDirectory")) {
				Import-Module -Name ActiveDirectory
			}
		}
		catch {
			Write-Warning "Failed to Import REQUIRED Active Directory Module...exiting script"
			Write-Warning "`nhttp://technet.microsoft.com/en-us/library/ee617195.aspx"
		}
		$xl = New-Object -ComObject Excel.Application
		$xl.visible = $true
		$wb = $xl.Workbooks.Add()
		$ws = $wb.WorkSheets.Item(1)
		$ws.Cells.Item(1, 1) = "Server                 "
		$ws.Cells.Item(1, 2) = "Reboot Date            "
		$ws.Cells.Item(1, 1).ColumnWidth = 20
		$ws.Cells.Item(1, 2).ColumnWidth = 20
		$rangeColor = $ws.UsedRange
		$rangeColor.Font.Bold = $true
		$therow = 2
		$thecol = 1
	}
	
	PROCESS {
		
		function get-BootTime {
			[Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject -Class Win32_OperatingSystem -Computer $Computer | Select -Exp LastBootUpTime))
		}
		
		foreach ($Computer in $ComputerName) {
			$thecol = 1
			Try {
				Write-Verbose "Doing a spot check to see if we can query Win32_Processor data for $computer"
				$allgood = $True
				$proc = Get-WmiObject -Class Win32_processor -ComputerName $computer -ErrorAction Stop -ErrorVariable GetProcError
			}
			Catch {
				$allgood = $false
				Write-Verbose "Failed to get Win32_Processor data for $computer"
				Write-Error "An error occurred for computer - $computer. Error: $GetProcError"
				$ws.cells.Item($therow, $theCol) = $Computer
				$ws.Cells.Item($therow, $thecol).Interior.ColorIndex = 3
				$thecol++
				$ws.Cells.Item($therow, $thecol) = "Cannot Query"
				$ws.Cells.Item($therow, $thecol).Interior.ColorIndex = 3
				$therow++
			}
			if ($allgood) {
				$ws.cells.item($therow, $theCol) = $Computer
				$thecol++
				$LastBootUpTime = get-BootTime
				$ws.Cells.Item($therow, $thecol) = $LastBootUpTime
				$therow++
			}
		}
	}
	END {
		Write-Verbose "Formatting the excel spreadsheet"
		$ws.UsedRange.Columns.AutoFit()
		$ListObject = $ws.ListObjects.Add()
		$ListObject.TableStyle = 'TableStyleLight16'
	}
}