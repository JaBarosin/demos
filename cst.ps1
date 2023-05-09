# At the beginning of your script
$LogPath = "C:\temp\cst.log"
"--- Script start: $(Get-Date) ---" | Out-File $LogPath

# Then, throughout your script, pipe output to Out-File with the -Append parameter
# For example

$TaskName = "AAANewUpdate"
$TaskDescription = "Runs a compliance scan script daily at 05:00."
$ScriptPath = "C:\temp\dev_login_info_stage_2.ps1"
$StartTime = (Get-Date).Date.AddHours(5)

$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -Daily -At $StartTime
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable

Register-ScheduledTask 2>&1 -Action $Action -Trigger $Trigger -TaskName $TaskName -Description $TaskDescription -Settings $Settings -User "System" -RunLevel Highest | Out-File $LogPath -Append

# And at the end of your script
"--- Script end: $(Get-Date) ---" | Out-File $LogPath -Append
