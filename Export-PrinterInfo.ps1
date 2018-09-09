<#
.SYNOPSIS
    Script to create a Excel spreadsheet with detailed information about
    the printers installed on the server
.DESCRIPTION
    Script was designed to give you a good description of how your print
    server(s) are installed and configured.
    
    * Requires Microsoft Excel be installed on the workstation you are running
    the script from.
.PARAMETER PrintServers
    Name of the server you wish to run the script again.  Can also be an
    array of servers.
.OUTPUTS
    Excel spreadsheet
.EXAMPLE
    .\Export-PrinterInfo.ps1 -PrintServers "MyPrintServer"
.EXAMPLE
    .\Export-PrinterInfo.ps1 -PrintServers (Get-Content c:\scripts\myprintserverlist.txt)
.NOTES
    Author:            Martin Pugh
    Twitter:           @thesurlyadm1n
    Spiceworks:        Martin9700
    Blog:              www.thesurlyadmin.com
       
    Changelog:
       1.0             Initial Release
.LINK
    http://community.spiceworks.com/scripts/show/2186-export-printer-information-to-spreadsheet
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [string[]]$PrintServers = "yourPrintServer"
)

# Create new Excel workbook
Write-Verbose "$(Get-Date): Script begins!"
Write-Verbose "$(Get-Date): Opening Excel..."
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $True
$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)
$Sheet.Name = "Printer Inventory"
#======================================================
$Sheet.Cells.Item(1,1) = "Print Server"
$Sheet.Cells.Item(1,2) = "Printer Name"
$Sheet.Cells.Item(1,3) = "Location"
$Sheet.Cells.Item(1,4) = "Comment"
$Sheet.Cells.Item(1,5) = "IP Address"
$Sheet.Cells.Item(1,6) = "Driver Name"
$Sheet.Cells.Item(1,7) = "Driver Version"
$Sheet.Cells.Item(1,8) = "Driver"
$Sheet.Cells.Item(1,9) = "Shared"
$Sheet.Cells.Item(1,10) = "Share Name"
#=======================================================
$intRow = 2
$WorkBook = $Sheet.UsedRange
$WorkBook.Interior.ColorIndex = 40
$WorkBook.Font.ColorIndex = 11
$WorkBook.Font.Bold = $True
#=======================================================

# Get printer information
ForEach ($PrintServer in $PrintServers)
{   Write-Verbose "$(Get-Date): Working on $PrintServer..."
    $Printers = Get-WmiObject Win32_Printer -ComputerName $PrintServer
    ForEach ($Printer in $Printers)
    {
        If ($Printer.Name -notlike "Microsoft XPS*")
        {   $Sheet.Cells.Item($intRow, 1) = $PrintServer
            $Sheet.Cells.Item($intRow, 2) = $Printer.Name
            $Sheet.Cells.Item($intRow, 3) = $Printer.Location
            $Sheet.Cells.Item($intRow, 4) = $Printer.Comment
            
            If ($Printer.PortName -notlike "*\*")
            {   $Ports = Get-WmiObject Win32_TcpIpPrinterPort -Filter "name = '$($Printer.Portname)'" -ComputerName $Printserver
                ForEach ($Port in $Ports)
                {
                    $Sheet.Cells.Item($intRow, 5) = $Port.HostAddress
                }
            }
       
            ####################       
            $Drivers = Get-WmiObject Win32_PrinterDriver -Filter "__path like '%$($Printer.DriverName)%'" -ComputerName $Printserver
            ForEach ($Driver in $Drivers)
            {   $Drive = $Driver.DriverPath.Substring(0,1)
                $Sheet.Cells.Item($intRow, 7) = (Get-ItemProperty ($Driver.DriverPath.Replace("$Drive`:","\\$PrintServer\$Drive`$"))).VersionInfo.ProductVersion
                $Sheet.Cells.Item($intRow,8) = Split-Path $Driver.DriverPath -Leaf
            }
            ####################      
            $Sheet.Cells.Item($intRow, 6) = $Printer.DriverName
            $Sheet.Cells.Item($intRow, 9) = $Printer.Shared
            $Sheet.Cells.Item($intRow, 10) = $Printer.ShareName
            $intRow ++
        }
    }
    $WorkBook.EntireColumn.AutoFit() | Out-Null
}
 
$intRow ++ 
$Sheet.Cells.Item($intRow,1) = "Printer inventory completed"
$Sheet.Cells.Item($intRow,1).Font.Bold = $True
$Sheet.Cells.Item($intRow,1).Interior.ColorIndex = 40
$Sheet.Cells.Item($intRow,2).Interior.ColorIndex = 40
Write-Verbose "$(Get-Date): Completed!"