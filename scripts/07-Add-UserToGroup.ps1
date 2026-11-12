# Add a user to a security group

$userName  = Read-Host "Enter the user's SamAccountName"
$groupName = Read-Host "Enter the group name"

Add-ADGroupMember -Identity $groupName -Members $userName
