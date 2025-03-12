# Remove Defender exclusions
Remove-MpPreference -ExclusionPath "C:\Program Files\Microsoft"
Remove-MpPreference -ExclusionPath "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# Unhide files and folders
attrib -h -s "C:\Program Files\Microsoft" /S /D
attrib -h -s "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" /S /D

# Force Windows Defender to apply changes immediately
Start-Process -FilePath "powershell.exe" -ArgumentList "Update-MpSignature" -WindowStyle Hidden -NoNewWindow
