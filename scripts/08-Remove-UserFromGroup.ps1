# Remove a user from a security group (no confirmation prompt)

$userName  = Read-Host "Enter the user's SamAccountName"
$groupName = Read-Host "Enter the group name"

Remove-ADGroupMember -Identity $groupName -Members $userName -Confirm:$false
