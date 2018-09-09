#script takes in a computer name and remotely forces user to log off. 
#
# Valid arguments for Win32Shutdown method:
#
# 0 Log Off
# 0 + 4 Forced Log Off
# 1 Shutdown
# 1 + 4 Forced Shutdown
# 2 Reboot
# 2 + 4 Forced Reboot
# 8 Power Off
# 8 + 4 Forced Power Off

$comp = read-host "AL1D29641"
(gwmi win32_operatingsystem -ComputerName $comp).Win32Shutdown(0)