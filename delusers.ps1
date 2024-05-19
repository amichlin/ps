
# Check if the script is running as Administrator
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Error "This script must be run as Administrator."
    exit
}

# List of usernames to keep
$keepUsers = @("Adam Michlin", "Administrator", "WDAGUtilityAccount", "Guest", "DefaultAccount")

# Get all local users
$allUsers = Get-LocalUser

# Loop through each user
foreach ($user in $allUsers) {
    # Check if the user is not in the keepUsers list
    if ($user.Name -notin $keepUsers) {
        # Delete the user
        Remove-LocalUser -Name $user.Name
        Write-Output "Deleted user: $($user.Name)"
    } else {
        Write-Output "Skipped user: $($user.Name)"
    }
}
