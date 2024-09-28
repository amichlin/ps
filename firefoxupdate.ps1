#Not verfied as working

# Define the URL for the latest Firefox installer
$firefoxInstallerUrl = "https://download.mozilla.org/?product=firefox-latest&os=win&lang=en-US"

# Define the local file path to download the installer
$installerPath = "$env:TEMP\FirefoxInstaller.exe"

# Download the Firefox installer
Write-Host "Downloading the latest Firefox installer..."
Invoke-WebRequest -Uri $firefoxInstallerUrl -OutFile $installerPath

# Check if the installer was downloaded
if (Test-Path $installerPath) {
    Write-Host "Firefox installer downloaded successfully."
    
    # Run the installer silently to update Firefox
    Write-Host "Installing/Updating Firefox..."
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
    
    # Check if Firefox is installed or updated
    $firefoxPath = Get-Command "firefox.exe" -ErrorAction SilentlyContinue
    if ($firefoxPath) {
        Write-Host "Firefox has been successfully installed/updated."
    } else {
        Write-Host "Firefox installation/update failed."
    }
    
    # Clean up the installer
    Remove-Item $installerPath
} else {
    Write-Host "Failed to download the Firefox installer."
}
