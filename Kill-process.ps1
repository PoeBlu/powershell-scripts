<#  
    .SYNOPSIS  
        Kill process

    .DESCRIPTION  
        This script will kill process by name on a computer(s) on the network. Writes events to an Application event log from "Kill process" source.
 
    .PARAMETER ComputerName  
        One or more computers to run command against

    .PARAMETER ProcessName 
        Process name to terminate
     
    .EXAMPLE  
        .\Kill-process.ps1 -ProcessName mspaint.exe

        Terminates mspaint.exe process on localhost
 
    .EXAMPLE  
        .\Kill-process.ps1 -Computername PC01 -ProcessName mspaint.exe

        Terminates mspaint.exe process on PC01

      .EXAMPLE  
        .\Kill-process.ps1 -Computername PC01, PC02 -ProcessName mspaint.exe

        Terminates mspaint.exe process on PC01 and PC02
#> 

[cmdletbinding()]
param(
    $ComputerName=$env:COMPUTERNAME,
    [parameter(Mandatory=$true)]
    $ProcessName
)

$EventSource = [System.Diagnostics.EventLog]::SourceExists("Kill process")

    if($EventSource -eq $False){
        $newEventSource = New-EventLog -LogName Application -Source "Kill process"
        Write-EventLog –LogName Application –Source "Kill process" –EntryType Information –EventID 1 –Message “Created a new event source.”
    }

$Processes = Get-WmiObject -Class Win32_Process -ComputerName $ComputerName -Filter "name='$ProcessName'"

    if($Processes -eq $null){
        Write-EventLog –LogName Application –Source "Kill process" –EntryType Information –EventID 0 –Message “Process $ProcessName does not exits on $ComputerName”
    }


foreach ($process in $processes){
    
    $processid = $process.handle
    $ownerName = $process.getowner().user
    $OwnerDomain= $process.getowner().domain
    $compName = $process.pscomputername
    $ret = $process.terminate()

    if($ret.returnvalue -eq 0){
        Write-EventLog –LogName Application –Source "Kill process" –EntryType Information –EventID 0 –Message “Process $ProcessName `($processid`) $OwnerDomain\$ownerName on $compName terminated successfully.”
    }
    else{
        Write-EventLog –LogName Application –Source "Kill process" –EntryType Error –EventID $ret.returnvalue –Message “Process $ProcessName `($processid`) on $compName NOT terminated successfully.”
    }
}