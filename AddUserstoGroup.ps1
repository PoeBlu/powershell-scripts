# Import active directory module for running AD cmdlets
Import-module ActiveDirectory

#Store the data from UserList.csv in the $List variable
$List = Import-CSV H:\UserGroupsList.xlsx

#Loop through user in the CSV
ForEach ($User in $List)
{

#Add the user to the TestGroup1 group in AD
Add-ADGroupMember -Identity IT Stuff ReadWrite -Member $User.username
}