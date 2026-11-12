# Bulk-create AD users from a CSV file
# CSV columns: FirstName,LastName,OU,Password  (see Bulk_Users.sample.csv)

Import-Csv -Path "C:\Users\administrator.ADLAB\Desktop\powershell scripts\Bulk_Users.csv" | ForEach-Object {
    $samAccountName    = $_.FirstName + $_.LastName.Substring(0,1)
    $userPrincipalName = $samAccountName + "@adlab.local"
    $password          = ConvertTo-SecureString $_.Password -AsPlainText -Force
    $ouPath            = $_.OU

    New-ADUser -Name "$($_.FirstName) $($_.LastName)" -GivenName $_.FirstName -Surname $_.LastName `
        -SamAccountName $samAccountName -UserPrincipalName $userPrincipalName `
        -Path $ouPath -AccountPassword $password -Enabled $true
}
