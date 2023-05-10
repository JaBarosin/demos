# Logging
$LogPath = "C:\temp\create_read_excel.log"
"--- Script start: $(Get-Date) ---" | Out-File $LogPath

$TaskName = "AAAReadExcel"
$TaskDescription = "Runs a compliance scan script at user login."
$ScriptPath = "C:\temp\ReadExcel.ps1"
$StartTime = (Get-Date).AddMinutes(2)
$TaskTime = Get-Date -Hour $StartTime.Hour -Minute $StartTime.Minute -Second $StartTime.Second


$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -Daily -At $TaskTime
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable

Register-ScheduledTask 2>&1 -Action $Action -Trigger $Trigger -TaskName $TaskName -Description $TaskDescription -Settings $Settings -User "svc_monitor" -RunLevel Highest | Out-File $LogPath -Append

"--- Script end: $(Get-Date) ---" | Out-File $LogPath -Append
