# Check if the username is passed as an argument
param (
    [Parameter(Mandatory=$true)]
    [string]$Username
)

# Check if the Username parameter was provided
if (-not $Username) {
    Write-Host "Usage: .\scriptname.ps1 -Username <username>"
    Exit
}

# Define the password
$Password = ConvertTo-SecureString "ReallyStrongPassword!01" -AsPlainText -Force

# Create the new user with the specified password
New-LocalUser -Name $Username -Password $Password -Description "New User Added via PowerShell"

# Add the user to the "Users" group (default)
Add-LocalGroupMember -Group "Users" -Member $Username

Write-Host "User $Username has been successfully added to the system with a preset password."
