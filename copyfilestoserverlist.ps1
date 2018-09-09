$server_names = Get-Content "H:\Servers_list.txt"
Foreach ($server in $server_names){
             Copy-Item "\\al130-fs-02.endo.com\ITHardware\Other\RAM.url" -Destination "\\$server\C$\users\Public\Desktop\" -Recurse
}
