param (
    [string[]] $serverNames = $( throw 'The list of server names was not provided' ),
    [int] $coresPerServer = $( throw 'The number of cores per server was not provided' ),
    [int] $repetitions = 1,
    [int] $intervalInSeconds = 60
)

1..$repetitions | foreach-object {
    $repetition = $_
    [DateTime] $now = [DateTime]::Now
    Write-Host "Getting CPU utilizations at $now (repetition $repetition)" -foregroundColor Green

    foreach ($server in $serverNames)
    {
        Write-Host "    Getting processes on $server" -foregroundColor Cyan
        
        $prc = gwmi Win32_PerfFormattedData_PerfProc_Process -computerName $server  # To get around bug where it is zero the first time called
        $prc = gwmi Win32_PerfFormattedData_PerfProc_Process -computerName $server | ? { $_.Name -ne '_Total' -and $_.Name -ne 'Idle' }
        $recordedAt = [DateTime]::Now
        
        $summary = $prc | select-object IDProcess,Name,PercentProcessorTime,WorkingSet,@{n='PercentTime';e={$_.PercentProcessorTime/$coresPerServer}}
        
        foreach ($processSummary in $summary)
        {
            $processName = $processSummary.Name
            $processName = ($processName.Split('#'))[0]
            $percentTime = $processSummary.PercentTime
            $workingSet = $processSummary.WorkingSet
            
            $record = new-object -typeName 'PSObject' -property @{
                Server = $server
                Process = $processName
                Repetition = $repetition
                AvgCPU = [Math]::Round( $percentTime, 2 )
                WorkingSet = $workingSet
                RecordedAt = $recordedAt
                Year = $recordedAt.Year
                Month = $recordedAt.Month
                Day = $recordedAt.Day
                DayOfWeek = $recordedAt.DayOfWeek
                Hour = $recordedAt.Hour
                Minute = $recordedAt.Minute
            }
            $record
        }
    }
    
    $timeTillNextRepetition = $now.AddSeconds($intervalInSeconds) - [DateTime]::Now
    $secondsToWait = $timeTillNextRepetition.TotalSeconds
    if ($secondsToWait -gt 0)
    {
        Start-Sleep -Seconds $secondsToWait
    }
}
