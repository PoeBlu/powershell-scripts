Param($outFile = "Results_Uninstall_" + $(Get-date -f "yyyyMMddHHmm") + ".csv",
$inFile = "List.csv")
# Uninstall-Software.ps1
#
# Description:
#
#   uninstalls the software provided in List.CSV file
#   List.csv - Should have 2 columns  "ServerName" and "SoftwareName"
#
# Modification History:
#
#   Date        Person              Description
#   ----------  -----------------   -------------------------------
#  06/06/2014     Basheer Ahmed       Original Version
#
#-------------------------------------------------------------------


$ErrorActionPreference = "stop"

Function Uninstall-Software {

PROCESS{
trap{
$obj = New-Object PSObject
$obj | Add-Member NoteProperty ServerName $serverName
$obj | Add-Member NoteProperty SoftwareName $softwareName
$obj | Add-Member NoteProperty Status $null
$obj| Add-Member NoteProperty Error	$(([string]$_.Exception.Message))
Write-Object $Obj

}

$serverName  = ($_.ServerName).trim()
$softwareName = ($_.SoftwareName).trim()



$conn = Get-WMIObject -Query $("Select * from Win32_Product where Name like '" + $softwareName + "%'" )  -ComputerName $serverName -EA "stop"
$res = $conn.Uninstall()

if($res.ReturnValue -eq 0){
# Success
$obj = New-Object PSObject
$obj | Add-Member NoteProperty ServerName $serverName
$obj | Add-Member NoteProperty SoftwareName $softwareName
$obj | Add-Member NoteProperty Status "Success"
$obj | Add-Member NoteProperty Error  $null
Write-Object $Obj


}Else{
#Failed
$obj = New-Object PSObject
$obj | Add-Member NoteProperty ServerName $serverName
$obj | Add-Member NoteProperty SoftwareName $softwareName
$obj | Add-Member NoteProperty Status "Failed"
$obj | Add-Member NoteProperty Error  $null
Write-Object $Obj

}

}
END{
$obj = New-Object PSObject
$obj | Add-Member NoteProperty ServerName "END_OF_REPORT!"
Write-Object $Obj
}

}

$inFile | Uninstall-Software | Export-CSV -path C:\Users\jaime.denys\desktop -force -Notypeinformation