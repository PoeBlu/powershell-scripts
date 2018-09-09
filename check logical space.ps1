$LogicalDisks = Get-WMIObject Win32_LogicalDisk
 $LocalHDisks = $LogicalDisks | Where-Object { $_.DriveType -eq 3 }
 $RemoteDrives = Get-WMIObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 4 }
 $OpticalDrives = Get-WMIObject Win32_CDRomDrive
$LocalHDisks | ft -auto @{Label="Drive";`
                           Expression={$_.DeviceID};
                           width=5
                           align="Right"},`
                        @{Label="Volume Label";`
                           Expression={$_.VolumeName};                                                         
                           Width=25},` 
                        @{Label="%Free";`
                           Expression={[int]($_.FreeSpace/$_.Size * 100)};`
                           Width=8},`
                        @{Label="GBFree";`
                           Expression={$([math]::round(($_.FreeSpace/1gb),0))};`
                           Width=8},`
                        @{Label="Size(GB)";`
                           Expression={$([math]::round(($_.Size/1gb),0))};`
                           Width=8}
 $OpticalDrives | Sort Drive | ft -auto `
                        @{Label="Drive";`
                           Expression={$_.Drive};`
                           Width=5
                           Align="Right"},
                        @{Label="Capabilities";`
                           Expression={ if ($_.Capabilities -eq 4) { `
                             "Read/Write" `
                           } else { `
                             "Read-Only"}}},`
                        @{Label="Disk Volume Label";`
                           Expression={$_.VolumeName}}
 $RemoteDrives | ft -auto @{Label="Drive";`
                           Expression={$_.DeviceID};`
                           width=5
                           align="Right"},`
                        @{Label="Remote Share";`
                           Expression={$_.ProviderName};`
                           Width=25},
                        @{Label="%Free";`
                           Expression={[int]($_.FreeSpace/$_.Size * 100)};`
                           Width=8},`
                        @{Label="GBFree";`
                           Expression={$([math]::round(($_.FreeSpace/1gb),0))};`
                           Width=8},`
                        @{Label="Size(GB)";`
                           Expression={$([math]::round(($_.Size/1gb),0))};`
                           Width=8}
 