# A script for quickly searching Active Directory and resetting the password of a user.
# Handy if you work in an environment where you reset passwords often (for example, a school).
# Written by C L Bonner, 2025.

$wordlist = Import-Csv -Header 'word' wordlist.txt

while ($true) {
    $word1 = Get-Random -InputObject $wordlist
    $word2 = Get-Random -InputObject $wordlist
    $number = Get-Random -Minimum 1 -Maximum 100
    $password = $word1.word.ToUpper() + $word2.word.ToLower() + $number.ToString()

    Clear-Host
    Write-Host " ########################################"
    Write-Host "# Active Directory Random Password Reset #"
    Write-Host "# Press Ctrl-C to exit                   #"
    Write-Host " ########################################`n"
    $search = Read-Host -Prompt "Enter name to search"

    if ($search -ne "" -and $search.ToLower() -ne "exit") {
        $filter = "Name -like '$search*'"
        $accounts = Get-ADUser -Filter $filter

        if ($accounts.Count -eq 0) { Write-Host -ForegroundColor Red "`nNo users found! Try again.`n" }
        elseif ($accounts.Count -gt 1) {
            for ($i = 0; $i -lt $accounts.Count; $i++) {
                Write-Host "$i : $($accounts[$i].Name) ($($accounts[$i].SamAccountName))"
            }
            $i = Read-Host "`nSelect a user"
            $account = $accounts[$i]
        }
        else { 
            $account = $accounts
        }

        $confirm = Read-Host "Please confirm you want to reset the password for $($account.Name) ($($account.SamAccountName)) y/n?"
        if ($confirm.ToUpper() -eq "Y") {
            Set-ADAccountPassword -Identity $account -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)
            Write-Host -ForegroundColor Green "`nPassword for $($account.Name) ($($account.SamAccountName)) has been set to $password`n"
        }
        Read-Host "Press return to clear screen"
    }
    
}
