# Enable the firewall for all profiles (Domain, Private, and Public)
Write-Host "Enabling Windows Firewall for all profiles..."

# Enable Firewall for Domain Profile
Set-NetFirewallProfile -Profile Domain -Enabled True
Write-Host "Domain firewall profile enabled."

# Enable Firewall for Private Profile
Set-NetFirewallProfile -Profile Private -Enabled True
Write-Host "Private firewall profile enabled."

# Enable Firewall for Public Profile
Set-NetFirewallProfile -Profile Public -Enabled True
Write-Host "Public firewall profile enabled."

# Ensure inbound and outbound filtering is enabled for all profiles
Write-Host "Enabling inbound and outbound filtering for all profiles..."

Set-NetFirewallProfile -Profile Domain -DefaultInboundAction Block -DefaultOutboundAction Allow
Write-Host "Domain profile: Inbound traffic blocked, outbound traffic allowed."

Set-NetFirewallProfile -Profile Private -DefaultInboundAction Block -DefaultOutboundAction Allow
Write-Host "Private profile: Inbound traffic blocked, outbound traffic allowed."

Set-NetFirewallProfile -Profile Public -DefaultInboundAction Block -DefaultOutboundAction Allow
Write-Host "Public profile: Inbound traffic blocked, outbound traffic allowed."

# Ensure notifications for blocked inbound traffic are enabled
Write-Host "Enabling notifications for blocked inbound traffic..."
Set-NetFirewallProfile -Profile Domain -NotifyOnListen True
Set-NetFirewallProfile -Profile Private -NotifyOnListen True
Set-NetFirewallProfile -Profile Public -NotifyOnListen True

# Display firewall status
Write-Host "Displaying current firewall status:"
Get-NetFirewallProfile | Format-Table Name, Enabled, DefaultInboundAction, DefaultOutboundAction, NotifyOnListen

Write-Host "All firewall features have been successfully enabled."
