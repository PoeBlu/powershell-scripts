$wmi = Get-WmiObject -Class Win32_OperatingSystem -Computer "al130-fs-02"
$wmi.ConvertToDateTime($wmi.LastBootUpTime)
  <#bookmark NewBookmark #>