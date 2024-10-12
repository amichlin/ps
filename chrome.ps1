# PowerShell script to update Google Chrome to the latest version

# Define the URL for the Google Chrome installer (64-bit)
$chromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"

# Define the local path to save the installer
$chromeInstallerPath = "$env:TEMP\chrome_installer.exe"

# Download the Google Chrome installer
Write-Host "Downloading the latest Google Chrome installer..."
Invoke-WebRequest -Uri $chromeInstallerUrl -OutFile $chromeInstallerPath

# Check if the file was downloaded successfully
if (Test-Path $chromeInstallerPath) {
    Write-Host "Download complete. Installing Google Chrome..."
    
    # Run the installer silently
    Start-Process -FilePath $chromeInstallerPath -ArgumentList "/silent", "/install" -Wait
    
    # Check if Chrome was installed successfully
    if (Get-Process "chrome" -ErrorAction SilentlyContinue) {
        Write-Host "Google Chrome is updated to the latest version."
    } else {
        Write-Host "Google Chrome installation failed."
    }
    
    # Remove the installer file
    Remove-Item $chromeInstallerPath -Force
} else {
    Write-Host "Failed to download the Google Chrome installer."
}
