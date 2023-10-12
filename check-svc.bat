# Create the BAT file
$batContent = @"
@echo off
sc query > C:\Users\service_status.log
"@

$batFilePath = "C:\Users\CheckServices.bat"
Set-Content -Path $batFilePath -Value $batContent

# Create the Scheduled Task
$action = New-ScheduledTaskAction -Execute "$batFilePath"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Saturday -At "5am"
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "CheckServicesTask" -User "NT AUTHORITY\SYSTEM"
