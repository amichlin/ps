# Create the "hypersonic" group if it doesn't exist
if (-not (Get-LocalGroup -Name "hypersonic" -ErrorAction SilentlyContinue)) {
    Write-Host "Creating 'hypersonic' group..."
    New-LocalGroup -Name "hypersonic"
} else {
    Write-Host "'hypersonic' group already exists."
}

# Define the list of users to add
$usersToAdd = @("ntrace", "mgarcia", "bcoleman", "alexei")

# Add each user to the "hypersonic" group
foreach ($user in $usersToAdd) {
    if (Get-LocalUser -Name $user -ErrorAction SilentlyContinue) {
        Add-LocalGroupMember -Group "hypersonic" -Member $user
        Write-Host "Added $user to 'hypersonic' group."
    } else {
        Write-Host "User $user does not exist. Skipping..."
    }
}

Write-Host "Operation complete."
