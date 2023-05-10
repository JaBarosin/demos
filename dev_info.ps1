Function Find-PSScriptsInPSAppLog
{
<#
.SYNOPSIS

Go through the PowerShell operational log to find scripts that run (by looking for ExecutionPipeline logs eventID 4100 in PowerShell app log).
You can then backdoor these scripts or do other malicious things.

Function: Find-AppLockerLogs
Author: Joe Bialek, Twitter: @JosephBialek
Required Dependencies: None
Optional Dependencies: None

.DESCRIPTION

Go through the PowerShell operational log to find scripts that run (by looking for ExecutionPipeline logs eventID 4100 in PowerShell app log).
You can then backdoor these scripts or do other malicious things.

.EXAMPLE

Find-PSScriptsInPSAppLog
Find unique PowerShell scripts being executed from the PowerShell operational log.

.NOTES
.LINK

Blog: http://clymb3r.wordpress.com/
Github repo: https://github.com/clymb3r/PowerShell
#>

    param (
        [string]$LogFilePath = "C:\temp\Find-PSScriptsInPSAppLog.log"
    )

    $ReturnInfo = @{}
    $Logs = Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" -ErrorAction SilentlyContinue | Where {$_.Id -eq 4100}

    foreach ($Log in $Logs)
    {
        $ContainsScriptName = $false
        $LogDetails = $Log.Message -split "`r`n"

        $FoundScriptName = $false
        foreach($Line in $LogDetails)
        {
            if ($Line -imatch "^\s*Script\sName\s=\s(.+)")
            {
                $ScriptName = $Matches[1]
                $FoundScriptName = $true
            }
            elseif ($Line -imatch "^\s*User\s=\s(.*)")
            {
                $User = $Matches[1]
            }
        }

        if ($FoundScriptName)
        {
            $Key = $ScriptName + "::::" + $User

            if (!$ReturnInfo.ContainsKey($Key))
            {
                $Properties = @{
                    ScriptName = $ScriptName
                    UserName = $User
                    Count = 1
                    Times = @($Log.TimeCreated)
                }

                $Item = New-Object PSObject -Property $Properties
                $ReturnInfo.Add($Key, $Item)
            }
            else
            {
                $ReturnInfo[$Key].Count++
                $ReturnInfo[$Key].Times += ,$Log.TimeCreated
            }
        }
    }


    $ReturnInfo.Values | Out-File -FilePath $LogFilePath -Append
    return $ReturnInfo
}

Find-PSScriptsInPSAppLog -LogFilePath "C:\temp\findps_output.log"
