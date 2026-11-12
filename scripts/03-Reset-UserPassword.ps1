# Reset one user's password and force a change at next logon

$user     = Read-Host "Enter the username (sAMAccountName)"
$password = Read-Host -AsSecureString "Enter the new password"

Set-ADAccountPassword -Identity $user -NewPassword $password
Set-ADUser -Identity $user -ChangePasswordAtLogon $true
Write-Host "Password for $user has been reset successfully."
