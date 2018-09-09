Function DirX($directory)
{
    $output = @{}

    foreach ($singleDirectory in (Get-ChildItem $directory -Recurse -Directory))
    {
        $count = 0 
        foreach($singleFile in Get-ChildItem $singleDirectory.FullName)
        {
            $count++
        }
        $output.Add($singleDirectory.FullName,$count)
    }

    $output | Out-String
}

$FOLDER_ROOT = "C:\"
$OUTPUT_LOCATION = "OUT.txt"
Function DirX($FOLDER_ROOT)
{
    Remove-Item $OUTPUT_LOCATION

    foreach ($singleDirectory in (Get-ChildItem $directory -Recurse -Directory))
    {
        $count = Get-ChildItem $singleDirectory.FullName -File | Measure-Object | %{$_.Count}
        $summary = $singleDirectory.FullName+"    "+$count+"    "+$singleDirectory.LastAccessTime
        Add-Content $OUTPUT_LOCATION $summary
    }
}
DirX($FOLDER_ROOT)