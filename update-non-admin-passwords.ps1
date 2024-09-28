# Define the new password for regular (non-administrative) users
$newPassword = ConvertTo-SecureString "niNApr0je(t" -AsPlainText -Force

# Get a list of all local users
$localUsers = Get-LocalUser

# Get all members of the Administrators group using net localgroup
$adminGroupMembers = (net localgroup Administrators) | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -notmatch "command completed" -and $_ -notmatch "Alias" }

# Loop through each user
foreach ($user in $localUsers) {
    # Skip if the user is disabled
    if (-not $user.Enabled) {
        Write-Host "User $($user.Name) is disabled. Skipping..."
        continue
    }

    # Check if the user is part of the Administrators group by checking against adminGroupMembers
    if ($adminGroupMembers -contains $user.Name) {
        Write-Host "User $($user.Name) is an administrator. Skipping..."
    } else {
        # Change password for non-admin users
        Set-LocalUser -Name $user.Name -Password $newPassword
        Write-Host "Password for user $($user.Name) has been changed."
    }
}

Write-Host "Password update complete for all regular (non-administrative) users."
