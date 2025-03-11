# Remove Defender exclusions
Remove-MpPreference -ExclusionPath "C:\Program Files\Chrome"
Remove-MpPreference -ExclusionPath "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\run_hidden.vbs"

# Unhide files and folder
attrib -h -s "C:\Program Files\Chrome" /S /D
attrib -h -s "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\run_hidden.vbs"

# Force Windows Defender to apply changes immediately
Start-Process -FilePath "powershell.exe" -ArgumentList "Update-MpSignature" -WindowStyle Hidden -NoNewWindow
