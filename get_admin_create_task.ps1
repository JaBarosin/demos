$logFile = "C:\temp\scriptlog.txt"

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
}

Write-Log "Script start"

# Check if we are currently running with administrative privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "Not running as administrator, relaunching as administrator"

    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it's path
    $newProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Set the window style to normal
    $newProcess.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    Write-Log "Relaunched as administrator, exiting current process"
    
    # Exit from the current, unelevated, process
    exit
}

Write-Log "Running with admin privileges"

# Now running with admin privileges
# Your code goes here
Write-Log "About to execute C:\temp\cst.ps1"
Invoke-Expression -Command "C:\temp\cst.ps1"
Write-Log "Executed C:\temp\cst.ps1"

Write-Log "Script end"
