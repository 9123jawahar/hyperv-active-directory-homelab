# Disable user accounts that have not logged on in the last N days
# Lab run used 5 days to produce results quickly.

$daysInactive = 5
$time         = (Get-Date).AddDays(-$daysInactive)

Get-ADUser -Filter {LastLogonDate -lt $time} -Property LastLogonDate | ForEach-Object {
    Disable-ADAccount -Identity $_.SamAccountName
    Write-Host "Disabled user account:" $_.SamAccountName
}
