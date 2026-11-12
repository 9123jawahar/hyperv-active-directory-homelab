# Move a list of users into a target OU

$users    = "AhmedN", "DonJ", "MeerA", "echin"
$targetOU = "OU=Users,OU=USA,DC=adlab,DC=local"

foreach ($user in $users) {
    $userDN = (Get-ADUser -Identity $user).DistinguishedName
    Move-ADObject -Identity $userDN -TargetPath $targetOU
    Write-Host "$user has been moved to $targetOU."
}
