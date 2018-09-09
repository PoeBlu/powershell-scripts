Get-ADUser -Filter 'Enabled -eq $false' | Select-Object Name | Export-Csv H:\disabledcomputers1.csv
