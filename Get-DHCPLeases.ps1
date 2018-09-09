# Get-DHCPLeases.ps1

# Author : Assaf Miron

# Description : This Script is used to get all DHCP Scopes and Leases from a specific DHCP Server

#  

# Input : 

# Output: 3 Log Files - Scope Log, Client Lease Log, Reserved Clients Log



$DHCP_SERVER = "10.33.20.40" # The DHCP Server Name

$LOG_FOLDER = "D:\DHCP" # A Folder to save all the Logs

# Create Log File Paths

$ScopeLog = $LOG_FOLDER+"\ScopeLog.csv"

$LeaseLog = $LOG_FOLDER+"\LeaseLog.csv"

$ReservedLog = $LOG_FOLDER+"\ReservedLog.csv"



#region Create Scope Object

 # Create a New Object

 $Scope = New-Object psobject

 # Add new members to the Object

 $Scope | Add-Member noteproperty "Address" ""

 $Scope | Add-Member noteproperty "Mask" ""

 $Scope | Add-Member noteproperty "State" ""

 $Scope | Add-Member noteproperty "Name" ""

 $Scope | Add-Member noteproperty "LeaseDuration" ""

 

 # Create Each Member in the Object as an Array

 $Scope.Address = @()

 $Scope.Mask = @()

 $Scope.State = @()

 $Scope.Name = @()

 $Scope.LeaseDuration = @()

#endregion



#region Create Lease Object

 # Create a New Object

 $LeaseClients = New-Object psObject

 # Add new members to the Object

 $LeaseClients | Add-Member noteproperty "IP" ""

 $LeaseClients | Add-Member noteproperty "Name" ""

 $LeaseClients | Add-Member noteproperty "Mask" ""

 $LeaseClients | Add-Member noteproperty "MAC" ""

 $LeaseClients | Add-Member noteproperty "Expires" ""

 $LeaseClients | Add-Member noteproperty "Type" ""

 

 # Create Each Member in the Object as an Array

 $LeaseClients.IP = @()

 $LeaseClients.Name = @()

 $LeaseClients.MAC = @()

 $LeaseClients.Mask = @()

 $LeaseClients.Expires = @()

 $LeaseClients.Type = @()

#endregion



#region Create Reserved Object

 # Create a New Object

 $LeaseReserved = New-Object psObject

 # Add new members to the Object

 $LeaseReserved | Add-Member noteproperty "IP" ""

 $LeaseReserved | Add-Member noteproperty "MAC" ""

 

 # Create Each Member in the Object as an Array

 $LeaseReserved.IP = @()

 $LeaseReserved.MAC = @()

#endregion



#region Define Commands

 #Commad to Connect to DHCP Server

 $NetCommand = "netsh dhcp server \\$DHCP_SERVER"

 #Command to get all Scope details on the Server

 $ShowScopes = "$NetCommand show scope"

#endregion



function Get-LeaseType( $LeaseType )

{

# Input  : The Lease type in one Char

# Output  : The Lease type description

# Description : This function translates a Lease type Char to it's relevant Description



 Switch($LeaseType){

 "N" { return "None" }

 "D" { return "DHCP" }

 "B" { return "BOOTP" }

 "U" { return "UNSPECIFIED" }

 "R" { return "RESERVATION IP" } 

 }

}



function Check-Empty( $Object ){

# Input : An Object with values.

# Output : A Trimmed String of the Object or '-' if it's Null.

# Description : Check the object if its null or not and return it's value.

 If($Object -eq $null)

 {

 return "-"

 }

 else

 {

 return $Object.ToString().Trim()

 }

}



function out-CSV ( $LogFile, $Append = $false) {

# Input : An Object with values, Boolean value if to append the file or not, a File path to a Log File

# Output : Export of the object values to a CSV File

# Description : This Function Exports all the Values and Headers of an object to a CSV File.

#   The Object is recieved with the Input Const (Used with Pipelineing) or the $inputObject

 

 Foreach ($item in $input){

 # Get all the Object Properties

 $Properties = $item.PsObject.get_properties()

 # Create Empty Strings - Start Fresh

 $Headers = ""

 $Values = ""

 # Go over each Property and get it's Name and value

 $Properties | %{ 

 $Headers += $_.Name+"`t"

 $Values += $_.Value+"`t"

 }

 # Output the Object Values and Headers to the Log file

 If($Append -and (Test-Path $LogFile)) {

 $Values | Out-File -Append -FilePath $LogFile -Encoding Unicode

 }

 else {

 # Used to mark it as an Powershell Custum object - you can Import it later and use it

 # "#TYPE System.Management.Automation.PSCustomObject" | Out-File -FilePath $LogFile

 $Headers | Out-File -FilePath $LogFile -Encoding Unicode

 $Values | Out-File -Append -FilePath $LogFile -Encoding Unicode

 }

 }

}



#region Get all Scopes in the Server 

 # Run the Command in the Show Scopes var

 $AllScopes = Invoke-Expression $ShowScopes

 # Go over all the Results, start from index 5 and finish in last index -3

 for($i=5;$i -lt $AllScopes.Length-3;$i++)

 {

 # Split the line and get the strings

 $line = $AllScopes[$i].Split("-")

 $Scope.Address += Check-Empty $line[0]

 $Scope.Mask += Check-Empty $line[1]

 $Scope.State += Check-Empty $line[2]

 # Line 3 and 4 represent the Name and Comment of the Scope

 # If the name is empty, try taking the comment

 If (Check-Empty $line[3] -eq "-") {

 $Scope.Name += Check-Empty $line[4]

 }

 else { $Scope.Name += Check-Empty $line[3] }

 }

 

 # Get all the Active Scopes IP Address

 $ScopesIP = $Scope | Where { $_.State -eq "Active" } | Select Address

 # Go over all the Adresses to collect Scope Client Lease Details

 Foreach($ScopeAddress in $ScopesIP.Address){

 # Define some Commands to run later - these commands need to be here because we use the ScopeAddress var that changes every loop

 #Command to get all Lease Details from a specific Scope - when 1 is amitted the output includes the computer name

 $ShowLeases = "$NetCommand scope "+$ScopeAddress+" show clients 1"

 #Command to get all Reserved IP Details from a specific Scope

 $ShowReserved = "$NetCommand scope "+$ScopeAddress+" show reservedip"

 #Command to get all the Scopes Options (Including the Scope Lease Duration)

 $ShowScopeDuration = "$NetCommand scope "+$ScopeAddress+" show option"

 

 # Run the Commands and save the output in the accourding var

 $AllLeases = Invoke-Expression $ShowLeases 

 $AllReserved = Invoke-Expression $ShowReserved 

 $AllOptions = Invoke-Expression $ShowScopeDuration

 

 # Get the Lease Duration from Each Scope

 for($i=0; $i -lt $AllOptions.count;$i++) 

 { 

 # Find a Scope Option ID number 51 - this Option ID Represents  the Scope Lease Duration

 if($AllOptions[$i] -match "OptionId : 51")

 { 

 # Get the Lease Duration from the Specified line

 $tmpLease = $AllOptions[$i+4].Split("=")[1].Trim()

 # The Lease Duration is recieved in Ticks / 10000000

 $tmpLease = [int]$tmpLease * 10000000; # Need to Convert to Int and Multiply by 10000000 to get Ticks

 # Create a TimeSpan Object

 $TimeSpan = New-Object -TypeName TimeSpan -ArgumentList $tmpLease

 # Calculate the $tmpLease Ticks to Days and put it in the Scope Lease Duration

 $Scope.LeaseDuration += $TimeSpan.TotalDays

 # After you found one Exit the For

 break;

 } 

 }

 

 # Get all Client Leases from Each Scope

 for($i=8;$i -lt $AllLeases.Length-4;$i++)

 {

 # Split the line and get the strings

 $line = [regex]::split($AllLeases[$i],"\s{2,}")

 # Check if you recieve all the lines that you need

 $LeaseClients.IP += Check-Empty $line[0]

 $LeaseClients.Mask += Check-Empty $line[1].ToString().replace("-","").Trim()

 $LeaseClients.MAC += $line[2].ToString().substring($line[2].ToString().indexOf("-")+1,$line[2].toString().Length-1).Trim()

 $LeaseClients.Expires += $(Check-Empty $line[3]).replace("-","").Trim()

 $LeaseClients.Type += Get-LeaseType $(Check-Empty $line[4]).replace("-","").Trim()

 $LeaseClients.Name += Check-Empty $line[5]

 }

 

 # Get all Client Lease Reservations from Each Scope

 for($i=7;$i -lt $AllReserved.Length-5;$i++)

 {

 # Split the line and get the strings

 $line = [regex]::split($AllReserved[$i],"\s{2,}")

 $LeaseReserved.IP += Check-Empty $line[0]

 $LeaseReserved.MAC += Check-Empty $line[2]

 }

 }

#endregion 



#region Export all the Data to nice log files

 # Export all data to XML Files for  later review

 $LeaseClients | Export-Clixml -Path $LOG_FOLDER"\Clients.xml"

 $LeaseReserved | Export-Clixml -Path $LOG_FOLDER"\Reserved.xml"

 $Scope | Export-Clixml -Path $LOG_FOLDER"\Scope.xml"

 

 #region Create a Temp Scope Object

 # Create a New Object

 $tmpScope = New-Object psobject

 # Add new members to the Object

 $tmpScope | Add-Member noteproperty "Address" ""

 $tmpScope | Add-Member noteproperty "Mask" ""

 $tmpScope | Add-Member noteproperty "State" ""

 $tmpScope | Add-Member noteproperty "Name" ""

 $tmpScope | Add-Member noteproperty "LeaseDuration" ""

 #endregion

 

 #region Create a Temp Lease Object

 # Create a New Object

 $tmpLeaseClients = New-Object psObject

 # Add new members to the Object

 $tmpLeaseClients | Add-Member noteproperty "IP" ""

 $tmpLeaseClients | Add-Member noteproperty "Name" ""

 $tmpLeaseClients | Add-Member noteproperty "Mask" ""

 $tmpLeaseClients | Add-Member noteproperty "MAC" ""

 $tmpLeaseClients | Add-Member noteproperty "Expires" ""

 $tmpLeaseClients | Add-Member noteproperty "Type" ""

 #endregion

 

 #region Create a Temp Reserved Object

 # Create a New Object

 $tmpLeaseReserved = New-Object psObject

 # Add new members to the Object

 $tmpLeaseReserved | Add-Member noteproperty "IP" ""

 $tmpLeaseReserved | Add-Member noteproperty "MAC" ""

 #endregion

 

 # Go over all the scope addresses and export each detail to a temporary var and out to the log file

 For($l=0; $l -lt $Scope.Address.Length;$l++)

 {

 # Get all Scope details to a temp var

 $tmpScope.Address = $Scope.Address[$l]

 $tmpScope.Mask = $Scope.Mask[$l]

 $tmpScope.State = $Scope.State[$l]

 $tmpScope.Name = $Scope.Name[$l]

 if($Scope.LeaseDuration[$l] -ne $Null)

 {

 $tmpLease = $Scope.LeaseDuration[$l].ToString()

 $tmpScope.LeaseDuration = $Scope.LeaseDuration[$l].ToString()

 }

 else

 {

 $tmpScope.LeaseDuration = $tmpLease

 }

 # Export with the Out-CSV Function to the Log File

 $tmpScope | Out-csv $ScopeLog -append $True

 }

 

 # Go over all the Client Lease addresses and export each detail to a temporary var and out to the log file

 For($l=0; $l -lt $LeaseClients.IP.Length;$l++)

 {

 # Get all Scope details to a temp var

 $tmpLeaseClients.IP = $LeaseClients.IP[$l]

 $tmpLeaseClients.Name = $LeaseClients.Name[$l]

 $tmpLeaseClients.Mask =  $LeaseClients.Mask[$l]

 $tmpLeaseClients.MAC = $LeaseClients.MAC[$l]

 $tmpLeaseClients.Expires = $LeaseClients.Expires[$l]

 $tmpLeaseClients.Type = $LeaseClients.Type[$l]

 # Export with the Out-CSV Function to the Log File

 $tmpLeaseClients | out-csv $LeaseLog -append $true

 }

 

 # Go over all the Reserved Client Lease addresses and export each detail to a temporary var and out to the log file

 For($l=0; $l -lt $LeaseReserved.IP.Length;$l++)

 {

 # Get all Scope details to a temp var

 $tmpLeaseReserved.IP = $LeaseReserved.IP[$l]

 $tmpLeaseReserved.MAC = $LeaseReserved.MAC[$l]

 # Export with the Out-CSV Function to the Log File

 $tmpLeaseReserved | out-csv $ReservedLog -append $true

 }

#endregion 