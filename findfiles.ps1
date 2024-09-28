# Set the registry key to unhide file extensions
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$registryName = "HideFileExt"

# Set the value to 0 to unhide extensions
Set-ItemProperty -Path $registryPath -Name $registryName -Value 0

Write-Host "File extensions will now be visible."
# Set registry key to show hidden files
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$registryName = "Hidden"

# Set value to 1 to show hidden files
Set-ItemProperty -Path $registryPath -Name $registryName -Value 1

Write-Host "Hidden files will now be visible in File Explorer."
# Define the file extensions to search for
$extensions = @('*.txt', '*.mp3', '*.mp4', '*.wav', '*.zip', '*.exe', '*.csv')

# Define the path to search
$searchPath = "C:\Users"

# Search for files with the specified extensions in the search path
Write-Host "Searching for files with specified extensions in $searchPath..."

foreach ($ext in $extensions) {
    Get-ChildItem -Path $searchPath -Recurse -Filter $ext -ErrorAction SilentlyContinue | 
    ForEach-Object { $_.FullName } | 
    Write-Host
}

Write-Host "Search complete."
