# Bulk password reset + account unlock from a CSV file
# CSV columns: SamAccountName,NewPassword  (see bulk_user_reset_password.sample.csv)

Import-Csv -Path "C:\Users\administrator.ADLAB\Desktop\powershell scripts\bulk_user_reset_password.csv" | ForEach-Object {
    $password = ConvertTo-SecureString $_.NewPassword -AsPlainText -Force
    Set-ADAccountPassword -Identity $_.SamAccountName -NewPassword $password
    Unlock-ADAccount -Identity $_.SamAccountName
    Write-Host "Password for" $_.SamAccountName "has been reset successfully."
}
