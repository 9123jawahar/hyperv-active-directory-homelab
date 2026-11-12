# Create a single AD user interactively
# Lab: adlab.local | Run on: AD-server2 (Windows Server 2025) | Module: ActiveDirectory

$firstName         = Read-Host "Enter First Name"
$lastName          = Read-Host "Enter Last Name"
$samAccountName    = $firstName + $lastName.Substring(0,1)        # e.g. Test + 2 -> Test2
$userPrincipalName = $samAccountName + "@adlab.local"
$ouPath            = "OU=Temp Users,OU=USA,DC=adlab,DC=local"
$password          = Read-Host -AsSecureString "Enter Password"

New-ADUser -Name "$firstName $lastName" -GivenName $firstName -Surname $lastName `
    -SamAccountName $samAccountName -UserPrincipalName $userPrincipalName `
    -Path $ouPath -AccountPassword $password -Enabled $true
