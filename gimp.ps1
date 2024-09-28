# Define the URL for the latest GIMP installer (for Windows)
$gimpInstallerUrl = "https://download.gimp.org/mirror/pub/gimp/v2.10/windows/gimp-2.10.38-setup.exe"

# Define the local file path to download the installer
$installerPath = "$env:TEMP\GimpInstaller.exe"

# Download the GIMP installer
Write-Host "Downloading the latest GIMP installer..."
Invoke-WebRequest -Uri $gimpInstallerUrl -OutFile $installerPath

# Check if the installer was downloaded successfully
if (Test-Path $installerPath) {
    Write-Host "GIMP installer downloaded successfully."

    # Run the installer silently to update GIMP
    Write-Host "Installing/Updating GIMP..."
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT" -Wait

    # Check if GIMP was installed or updated
    $gimpPath = Get-Command "gimp-2.10.exe" -ErrorAction SilentlyContinue
    if ($gimpPath) {
        Write-Host "GIMP has been successfully installed/updated."
    } else {
        Write-Host "GIMP installation/update failed."
    }

    # Clean up the installer
    Remove-Item $installerPath
} else {
    Write-Host "Failed to download the GIMP installer."
}
