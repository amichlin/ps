# Check if PSWindowsUpdate module is installed
$moduleName = "PSWindowsUpdate"
$module = Get-Module -ListAvailable -Name $moduleName

# Function to install NuGet provider if not available
function Ensure-NuGetProvider {
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Host "NuGet provider is not installed. Installing now..."
        Install-PackageProvider -Name NuGet -Force -Confirm:$false
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    }
}

# Check and install NuGet provider if necessary
Ensure-NuGetProvider

if ($module) {
    Write-Host "$moduleName module is already installed."
} else {
    Write-Host "$moduleName module is not installed. Installing now..."
    
    # Install PSWindowsUpdate module
    Install-Module -Name $moduleName -Force -AllowClobber
    
    # Check if the installation was successful
    $module = Get-Module -ListAvailable -Name $moduleName
    if ($module) {
        Write-Host "$moduleName module installed successfully."
    } else {
        Write-Host "Failed to install $moduleName module."
        exit 1
    }
}

# Import the module if it hasn't been imported already
Import-Module PSWindowsUpdate

# Get available updates excluding those related to VMware
Write-Host "Checking for available updates..."
$updates = Get-WindowsUpdate | Where-Object { $_.Title -notlike "*VMware*" }

if ($updates) {
    Write-Host "Installing available updates (excluding VMware updates)..."
    Install-WindowsUpdate -AcceptAll -AutoReboot -NotCategory "VMware"
} else {
    Write-Host "No updates available or VMware updates ignored."
}

Write-Host "Update process completed."
