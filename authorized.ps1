# Helper function to strip domain from user name
function StripDomain {
    param (
        [string]$userName
    )
    if ($userName -contains "\\") {
        return ($userName -split "\\")[1]  # Split and return the username part
    }
    return $userName
}

# Modular helper function to check group membership
function IsMemberOfGroup {
    param (
        [string]$userName,
        [string]$groupName
    )
    try {
        return (Get-LocalGroupMember -Group $groupName | Where-Object { $_.Name -eq $userName }) -ne $null
    } catch {
        return $false
    }
}

# Modular function to ensure a user is in a group
function EnsureUserInGroup {
    param (
        [string]$userName,
        [string]$groupName
    )
    if (-not (IsMemberOfGroup -userName $userName -groupName $groupName)) {
        Add-LocalGroupMember -Group $groupName -Member $userName -ErrorAction SilentlyContinue
        Write-Host "$userName added to $groupName group."
    } else {
        Write-Host "$userName is already a member of $groupName group."
    }
}

# Modular function to remove a user from a group
function RemoveUserFromGroup {
    param (
        [string]$userName,
        [string]$groupName
    )
    if (IsMemberOfGroup -userName $userName -groupName $groupName) {
        Remove-LocalGroupMember -Group $groupName -Member $userName -ErrorAction SilentlyContinue
        Write-Host "$userName removed from $groupName group."
    }
}

# Authorized lists (without domain prefixes here)
$authorizedAdmins = @{
    "Administrator" = ""
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

$systemAccounts = @("DefaultAccount", "Guest", "WDAGUtilityAccount")

$adminGroup = "Administrators"
$userGroup = "Users"

# Normalize authorized admin names (no domain prefixes)
$normalizedAuthorizedAdmins = $authorizedAdmins.Keys | ForEach-Object { StripDomain $_ }

# Ensure only authorized admins remain as admins
$localAdmins = Get-LocalGroupMember -Group $adminGroup | Where-Object { $_.ObjectClass -eq 'User' }
foreach ($admin in $localAdmins) {
    $strippedName = StripDomain $admin.Name
    # Check if the strippedName is in the list of authorized admins
    if ($normalizedAuthorizedAdmins -contains $strippedName) {
        Write-Host "$admin.Name (authorized admin) remains in the Admin group."
    } else {
        Write-Host "Unauthorized admin $admin.Name will be downgraded."
        RemoveUserFromGroup -userName $admin.Name -groupName $adminGroup
        EnsureUserInGroup -userName $admin.Name -groupName $userGroup
    }
}

# Ensure passwords for authorized admins (excluding Administrator which does not have a predefined password)
foreach ($admin in $authorizedAdmins.Keys) {
    if ($admin -ne "Administrator") {
        $password = ConvertTo-SecureString $authorizedAdmins[$admin] -AsPlainText -Force
        Set-LocalUser -Name $admin -Password $password
        Write-Host "Updated password for admin $admin."
    }
}

# Promote users who should be admins but are not
foreach ($admin in $authorizedAdmins.Keys) {
    EnsureUserInGroup -userName $admin -groupName $adminGroup
}

# Normalize authorized user names (no domain prefixes)
$normalizedAuthorizedUsers = $authorizedUsers | ForEach-Object { StripDomain $_ }

# Ensure only authorized users remain in the Users group
$localUsers = Get-LocalGroupMember -Group $userGroup | Where-Object { $_.ObjectClass -eq 'User' }
foreach ($user in $localUsers) {
    $strippedName = StripDomain $user.Name
    if (-not $normalizedAuthorizedUsers -contains $strippedName -and `
        -not $normalizedAuthorizedAdmins -contains $strippedName -and `
        $strippedName -ne "alexei") {
        if (Get-LocalUser -Name $strippedName -ErrorAction SilentlyContinue) {
            Remove-LocalUser -Name $strippedName -ErrorAction SilentlyContinue
            Write-Host "Deleted unauthorized user account $strippedName."
        } else {
            Write-Host "User $strippedName was not found."
        }
    } else {
        EnsureUserInGroup -userName $user.Name -groupName $userGroup
    }
}

# Clean up unauthorized local accounts
$allAccounts = Get-LocalUser
foreach ($account in $allAccounts) {
    $strippedName = StripDomain $account.Name
    if (-not $normalizedAuthorizedAdmins -contains $strippedName -and `
        -not $normalizedAuthorizedUsers -contains $strippedName -and `
        $strippedName -ne "alexei" -and `
        -not $systemAccounts.Contains($strippedName)) {
        
        if (Get-LocalUser -Name $strippedName -ErrorAction SilentlyContinue) {
            Remove-LocalUser -Name $strippedName -ErrorAction SilentlyContinue
            Write-Host "Deleted unauthorized account $strippedName."
        } else {
            Write-Host "Account $strippedName was not found."
        }
    }
}

Write-Host "Admin and user cleanup complete."
