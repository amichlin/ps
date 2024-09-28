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
