Get-ADGroupMember -identity "APPSEC_MDis_Admin_Group" | get-aduser | Where {$_.Enabled -eq $true} | format-table name, samaccountname -autosize 
