# Set the maximum password age to 90 days
net accounts /maxpwage:90

Write-Host "Maximum password age has been set to 90 days."

# Define a temporary path in the user's temp directory
$tempPath = [System.IO.Path]::GetTempPath()
$secpolFile = Join-Path $tempPath "secpol.cfg"

# Export current security policy settings to a file
secedit /export /cfg $secpolFile

# Modify the security policy settings
(gc $secpolFile) -replace "LockoutBadCount = 0", "LockoutBadCount = 10" | Set-Content $secpolFile
(gc $secpolFile) -replace "LockoutDuration = 0", "LockoutDuration = 14400" | Set-Content $secpolFile

# Apply the modified security policy settings
secedit /configure /db %windir%\security\database\secedit.sdb /cfg $secpolFile /quiet

# Clean up the temporary file
Remove-Item $secpolFile

# 1. Set account lockout threshold and duration

# Set the account lockout threshold to 10 invalid logon attempts
Write-Host "Setting account lockout threshold to 10 invalid attempts..."
net accounts /lockoutthreshold:10

# Set the lockout duration to 14400 minutes (10 days)
Write-Host "Setting account lockout duration to 10 days (14400 minutes)..."
net accounts /lockoutduration:14400

Write-Host "Account lockout threshold and duration have been configured."

# 2. Configure Audit Credential Validation to log failure events

# Enable failure auditing for Credential Validation
Write-Host "Configuring Audit Credential Validation to log failure events..."
auditpol /set /subcategory:"Credential Validation" /failure:enable

Write-Host "Audit Credential Validation set to log failures."
# Define the registry path and value
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$registryName = "RestrictAnonymousSAM"

# Set the value to 1 to disable anonymous enumeration of SAM accounts
Set-ItemProperty -Path $registryPath -Name $registryName -Value 1

Write-Host "Anonymous enumeration of SAM accounts has been disabled."

# Define the temporary file to store security policy export
$secpolFile = "$env:TEMP\secpol.txt"

# Export the current security policy to a temporary file
secedit /export /cfg $secpolFile /quiet

# Read the content of the exported security policy
$policyContent = Get-Content $secpolFile

# Search for SeSecurityPrivilege (Manage auditing and security log privilege)
$seSecurityPrivilegeLine = $policyContent | Select-String -Pattern "SeSecurityPrivilege"

# If SeSecurityPrivilege is found, extract the users/groups associated with it
if ($seSecurityPrivilegeLine) {
    $usersWithPrivilege = $seSecurityPrivilegeLine -replace "SeSecurityPrivilege = ", "" -replace '"', ""
    
    # Split the users/groups by comma and remove any empty entries
    $usersList = $usersWithPrivilege -split "," | Where-Object { $_.Trim() -ne "" }
    
    # Exclude the Administrators group
    $nonAdminUsers = $usersList | Where-Object { $_ -ne "Administrators" }

    if ($nonAdminUsers) {
        Write-Host "Users with 'SeSecurityPrivilege' (Manage auditing and security logs) that are NOT Administrators:"
        $nonAdminUsers | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "No non-administrator users have the 'SeSecurityPrivilege'."
    }
} else {
    Write-Host "No users found with 'SeSecurityPrivilege'."
}

# Clean up the temporary file
Remove-Item $secpolFile -Force

# Disable Remote Assistance via the registry
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance"
$registryName = "fAllowToGetHelp"

# Set the value to 0 to disable Remote Assistance
Set-ItemProperty -Path $registryPath -Name $registryName -Value 0

Write-Host "Remote Assistance has been disabled in the registry."

# Disable Remote Assistance through Group Policy settings
$gpeditPath = "HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services"
if (-not (Test-Path $gpeditPath)) {
    New-Item -Path $gpeditPath -Force | Out-Null
}

# Disable the Group Policy setting for Remote Assistance
Set-ItemProperty -Path $gpeditPath -Name "fAllowRemoteAssistance" -Value 0

Write-Host "Remote Assistance has been disabled via Group Policy"

# Disable Remote Desktop via the registry
$rdpRegPath = "HKLM:\System\CurrentControlSet\Control\Terminal Server"
$regName = "fDenyTSConnections"

# Set the value to 1 to disable RDP
Set-ItemProperty -Path $rdpRegPath -Name $regName -Value 1

Write-Host "RDP has been disabled via the registry."

# Stop the Remote Desktop Services service
Write-Host "Stopping Remote Desktop Services..."
Stop-Service -Name "TermService" -Force

Write-Host "Remote Desktop Services have been stopped."

# Confirm that RDP is disabled
$rdpStatus = Get-ItemProperty -Path $rdpRegPath -Name $regName
if ($rdpStatus.fDenyTSConnections -eq 1) {
    Write-Host "RDP is disabled."
} else {
    Write-Host "Failed to disable RDP."
}
