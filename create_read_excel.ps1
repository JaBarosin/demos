# Logging
$LogPath = "C:\temp\cst.log"
"--- Script start: $(Get-Date) ---" | Out-File $LogPath

$TaskName = "AAAReadExcel"
$TaskDescription = "Runs a compliance scan script at user login."
$ScriptPath = "C:\temp\ReadExcel.ps1"
$StartTime = (Get-Date).AddMinutes(15)

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -Daily -At $StartTime.TimeOfDay
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable

Register-ScheduledTask 2>&1 -Action $Action -Trigger $Trigger -TaskName $TaskName -Description $TaskDescription -Settings $Settings -User "System" -RunLevel Highest | Out-File $LogPath -Append

"--- Script end: $(Get-Date) ---" | Out-File $LogPath -Append
