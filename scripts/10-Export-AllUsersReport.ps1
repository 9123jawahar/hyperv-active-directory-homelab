# Export a report of all domain users

Get-ADUser -Filter * -Property DisplayName, SamAccountName, UserPrincipalName, EmailAddress, LastLogonDate |
    Select-Object DisplayName, SamAccountName, UserPrincipalName, EmailAddress, LastLogonDate |
    Export-Csv -Path "C:\Users\administrator.ADLAB\Desktop\powershell scripts\AllADUsers.csv" -NoTypeInformation
