# Export every user in one OU to CSV

$ouPath     = "OU=Temp Users,OU=USA,DC=adlab,DC=local"
$outputPath = "C:\Users\administrator.ADLAB\Desktop\powershell scripts\ADUsersExport.csv"

Get-ADUser -Filter * -SearchBase $ouPath -Properties Name, givenName, sAMAccountName, userPrincipalName, userAccountControl, cn, LastLogonDate, objectSid |
    Select-Object Name, givenName, sAMAccountName, userPrincipalName, userAccountControl, cn, LastLogonDate, objectSid |
    Export-Csv -Path $outputPath -NoTypeInformation

Write-Host "User information has been exported to $outputPath."
