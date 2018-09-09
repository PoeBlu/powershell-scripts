function Get-SPOWebs($url)
{

#fill metadata information to the client context variable

$context = New-Object Microsoft.SharePoint.Client.ClientContext($url)

$context.Credentials = $SPOcredentials

$web = $context.Web

$context.Load($web)

$context.Load($web.Webs)

$context.load($web.lists)

try{

$context.ExecuteQuery()

#loop through all lists in the web

foreach($list in $web.lists){

add-content -value "<tr><td><span style='margin-left:$($pixelslist)px'>$($list.title)</td><td>List/library</td><td></td><td>$($list.itemcount)</td></tr>" -path $filePath

}

#loop through all webs in the web and start again to find more subwebs

$pixelsweb = $pixelsweb + 15

$pixelslist = $pixelslist + 15

foreach($web in $web.Webs) {

add-content -value "<tr style='background-color:yellow'><td><span style='margin-left:$($pixelsweb)px'>$($web.url)</td><td>Web</td><td>$($web.webtemplate)</td><td></td></tr>" -path $filePath

write-host "Info: Found $($web.url)" -foregroundcolor green

Get-SPOWebs($web.url)

}

}

catch{

write-host "Could not find web" -foregroundcolor red

}
}

$fileCount = 0
$folderCount = 0
$itemcount = 0

# $Web = <Enter URL Here or use -- Read-host “Please enter the Url” To have it ask for the URL >
$Web = Read-host “Please enter the Url”
$WebObject = Get-SPOWebs $Web
$WebObject.Lists | Select Title
# $Library = < Enter Library name Here or use -- Read-Host “Please enter Library or list name” To have it ask for the share Library >
$Library = Read-Host “Please enter Library or list name”
$LibraryObject = $WebObject.Lists[“$Library”]

$itemcount = $LibraryObject.ItemCount

foreach ($folders in $LibraryObject.Folders)
{
$folder = $folders.Folder
$folderCount ++

    foreach ($file in $folder.Files)
    {
        $fileCount ++
        $filesizeinkb = ($file.length/1024)
        “{0}`t{1}`t{2}” -f $folder.Name, $file.Name, $filesizeinkb   | out-file Test.csv> -Append     
    }
   
}
Write-Host -ForegroundColor Green “Total Item Count ” $itemcount
Write-Host -ForegroundColor Green “Total File Count ” $fileCount
Write-Host -ForegroundColor Green “Total Folder Count ” $folderCount

$WebObject.Dispose()