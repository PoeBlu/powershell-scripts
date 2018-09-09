#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 


#requires -version 3.0

<#
 	.SYNOPSIS
        The PowerShell script which can be used to check if the server is pending reboot.
    .DESCRIPTION
        The PowerShell script which can be used to check if the server is pending reboot.
    .PARAMETER  ComputerName
		Gets the server reboot status on the specified computer.
    .EXAMPLE
        C:\PS> C:\Script\FindServerIsPendingReboot.ps1 -ComputerName "WIN-VU0S8","WIN-FJ6FH","WIN-FJDSH","WIN-FG3FH"

		ComputerName                                          RebootIsPending
        ------------                                          ---------------
        WIN-VU0S8                                             False
        WIN-FJ6FH                                             True
        WIN-FJDSH                                             True
        WIN-FG3FH                                             True

        This command will get the reboot status on the specified remote computers.
#>
param
(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [String[]]$ComputerName=$env:COMPUTERNAME
)

Foreach($cn in $ComputerName)
{
    #Declare the variable
    $PendingFile = $false
    $AutoUpdate = $false
    $CBS = $false 
    $SCCMPending = $false

    #Determine PendingFileRenameOperations exists of not 
    $PendFileKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\"
   
    Invoke-Command -ComputerName $cn -ScriptBlock{
    Get-ItemProperty -Path $using:PendFileKeyPath -name PendingFileRenameOperations} -ErrorAction SilentlyContinue |`
    Foreach{If($_.PendingFileRenameOperations){$PendingFile = $true}Else{$PendingFile = $false}}

    #Determine RebootRequired subkey exists or not
    $AutoUpdateKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
    Invoke-Command -ComputerName $cn -ScriptBlock {Test-Path -Path "$using:AutoUpdateKeyPath\RebootRequired"} |`
    Foreach{If($_ -eq $true){$AutoUpdate = $true}Else{$AutoUpdate = $false}}
    
    #Determine SCCM 2012 reboot require
    $SCCMReboot = Invoke-CimMethod -Namespace 'Root\ccm\clientSDK' -ClassName 'CCM_ClientUtilities' -ComputerName $cn `
    -Name 'DetermineIfRebootPending' -ErrorAction SilentlyContinue

    If($SCCMReboot)
    {
        If($SCCMReboot.RebootPending -or $SCCMReboot.IsHardRebootPending)
        {
            $SCCMPending = $true
        }
    }

    #Determine Component-Based Servicing reboot require
    #The servicing stack is available on all Windows Vista and Windows Server 2008 installations.
    $CBSKeyPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\"
    Invoke-Command -ComputerName $cn -ScriptBlock {Test-Path -Path "$using:CBSKeyPath\RebootPending"} |`
    Foreach{If($_ -eq $true){$CBS = $true}Else{$CBS = $false}}

    If($PendingFile -or $AutoUpdate -or $CBS -or $SCCMPending)
    {
        [PSCustomObject]@{ComputerName = $cn;RebootIsPending = $true}
    }
    Else
    {
        [PSCustomObject]@{ComputerName = $cn;RebootIsPending = $false}
    }
}
