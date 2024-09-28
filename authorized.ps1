# Authorized lists
$authorizedAdmins = @{
    "eleven" = "niNApr0je(t"
    "pmitchell" = "p4Lac|In11"
    "tkazansky" = "w@teRG/\t3"
    "ccain" = "ne\/er3ND5try"
    "bsimpson" = "inn3r5tRE|\|gth"
}

$authorizedUsers = @(
    "abenjamin", "bbradshaw", "rfloyd", "sbates", "bcoleman", "cbradshaw", 
    "ntrace", "rfitch", "mgarcia", "jmachado", "bavalone", "llee", 
    "blennox", "nvikander", "cbassett", "skazansky"
)

# Admin and user group names
$adminGroup = "Administrators"
$userGroup = "Users"

# Get list of local accounts
$localAdmins = Get-LocalGroupMember -Group $adminGroup | Where-Object { $_.ObjectClass -eq 'User' }
$localUsers = Get-LocalGroupMember -Group $userGroup | Where-Object { $_.ObjectClass -eq 'User' }

# Ensure only authorized admins remain as admins
foreach ($admin in $localAdmins) {
    if (-not $authorizedAdmins.ContainsKey($admin.Name) -and $admin.Name -ne "alexei") {
        # Downgrade unauthorized admin to user
        Remove-LocalGroupMember -Group $adminGroup -Member $admin.Name
        Add-LocalGroupMember -Group $userGroup -Member $admin.Name
        Write-Host "Downgraded $admin.Name from Admin to User."
    }
}

# Delete any accounts not in either list (except alexei)
$allAccounts = Get-LocalUser
foreach ($account in $allAccounts) {
    if (-not $authorizedAdmins.ContainsKey($account.Name) -and `
        -not $authorizedUsers.Contains($account.Name) -and `
        $account.Name -ne "alexei") {
        
        # Remove unauthorized account
        Remove-LocalUser -Name $account.Name
        Write-Host "Deleted unauthorized account $account.Name."
    }
}

# Ensure passwords for authorized admins
foreach ($admin in $authorizedAdmins.Keys) {
    $password = ConvertTo-SecureString $authorizedAdmins[$admin] -AsPlainText -Force
    Set-LocalUser -Name $admin -Password $password
    Write-Host "Updated password for admin $admin."
}

# Ensure only authorized users remain as users
foreach ($user in $localUsers) {
    if (-not $authorizedUsers.Contains($user.Name) -and `
        -not $authorizedAdmins.ContainsKey($user.Name) -and `
        $user.Name -ne "alexei") {
        
        # Remove unauthorized user
        Remove-LocalUser -Name $user.Name
        Write-Host "Deleted unauthorized user account $user.Name."
    }
}

Write-Host "Admin and user cleanup complete."
