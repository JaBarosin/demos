# Logging
$LogPath = "C:\temp\cst.log"
"--- Script start: $(Get-Date) ---" | Out-File $LogPath

$TaskName = "AAANewUpdate"
$TaskDescription = "Runs a compliance scan script at user login."
$ScriptPath = "C:\temp\dev_login_info_stage_2.ps1"

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -AtLogon
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable

Register-ScheduledTask 2>&1 -Action $Action -Trigger $Trigger -TaskName $TaskName -Description $TaskDescription -Settings $Settings -User "System" -RunLevel Highest | Out-File $LogPath -Append

"--- Script end: $(Get-Date) ---" | Out-File $LogPath -Append
