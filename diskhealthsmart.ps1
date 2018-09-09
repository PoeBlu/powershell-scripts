$WMI = Get-WMIObject -Computer MSSLW17100558.ndc.nasa.gov -Class Win32_DiskDrive
ForEach ($Drive in $WMI){
     $Drive.Caption + ": " + $Drive.Status
}