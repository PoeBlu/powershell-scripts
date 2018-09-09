$server_names = @("AL1l57815","al1d60050")
Foreach ($server in $server_names){
             Copy-Item "\\al130-fs-02\ITHardware\Other\JDE32bit_Production.bat" -Destination "\\$server\C$\users\Public\Desktop\" -Recurse
}