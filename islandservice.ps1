Set-PSDebug -Trace 1
Write-Output "Uninstalling Service"
if (Test-Path 'C:\\Program Files\\Island\\island-service-uninstaller') {
 if (Test-Path "C:\\Program Files\\Island\\island-service-uninstaller\\IslandServiceUninstaller.exe") {
     Write-Output "Uninstalling service"
     Start-Process -Wait -NoNewWindow -FilePath "C:\\Program Files\\Island\\island-service-uninstaller\\IslandServiceUninstaller.exe"
     Write-Output "Service uninstalled"
 }
 Remove-Item "C:\\Program Files\\Island\\island-service-uninstaller" -Recurse -Force -EA SilentlyContinue -Verbose
}
if (Test-Path 'C:\\EndpointAgent') {
 Remove-Item "C:\\EndpointAgent" -Recurse -Force -EA SilentlyContinue -Verbose
}
try {
   \$processes = Get-Process -Name "Island Service Agent" -ErrorAction SilentlyContinue

   # Check if the process was found
   if (\$processes) {
       # Loop through each instance and kill it
       foreach (\$process in \$processes) {
            Stop-Process -Id \$process.Id -Force
       }
   } else {
       Write-Host "Process 'Island Service Agent' not found."
   }
   \$uninstallKeyPath = "HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
   \$programName = "IslandServiceAgent"
   \$ProductName = "IslandBackgroundService"
   # Search for the program in the uninstall store
   \$uninstallKey = Get-ChildItem -Path \$uninstallKeyPath -Recurse | Where-Object { \$_.GetValue("DisplayName") -eq \$programName }

   if (\$uninstallKey) {
       # Remove the program from the uninstall store
       Remove-Item -Path \$uninstallKey.PSPath -Force
       Write-Host "Program '\$programName' has been removed from the uninstall store."
   } else {
       Write-Host "Program '\$programName' not found in the uninstall store."
   }

   \$serviceName = "Island Service"

   # Check if the service is running
   \$service = Get-Service -Name "\$serviceName" -ErrorAction SilentlyContinue
   if (\$service) {
       # Stop the service
       Stop-Service -Name "\$serviceName"
       Write-Host "Service '\$serviceName' has been stopped."
       sc.exe delete "\$serviceName"
   } else {
       Write-Host "Service '\$serviceName' not found."
   }

   \$serviceName = "Island Service Agent"

   # Check if the service is running
   \$service = Get-Service -Name "\$serviceName" -ErrorAction SilentlyContinue
   if (\$service) {
       # Stop the service
       Stop-Service -Name "\$serviceName"
       Write-Host "Service '\$serviceName' has been stopped."
       sc.exe delete Island Service Agent
   } else {
       Write-Host "Service '\$serviceName' not found."
   }

   \$serviceKeyPath = "HKLM:\\SYSTEM\\CurrentControlSet\\Services\\\$serviceName"

   # Check if the service registry key exists
   if (Test-Path -Path \$serviceKeyPath) {
       # Delete the service registry key
       Remove-Item -Path \$serviceKeyPath -Force
       Write-Host "Service '\$serviceName' has been removed from the registry."
   } else {
       Write-Host "Service '\$serviceName' registry key not found."
   }

   # Define the registry path
   \$registryPath = "HKLM:\\SOFTWARE\\Wow6432Node\\Island\\Update\\Clients\\{058172F1-17D2-4FCA-A3BD-40A5F0DD7237}"

   # Check if the registry key exists
   if (Test-Path -Path \$registryPath) {
      Remove-Item -Path \$registryPath -Force
   } else {
       Write-Host "Registry path '\$registryPath' not found."
   }

   \$islandServicePath = "C:\\Program Files\\Island\\Island Service"
   \$islandServiceDataPath = "C:\\ProgramData\\Island\\Island Service"
   if (Test-Path -Path "\$islandServicePath") {
      Remove-Item -Path "\$islandServicePath" -Force -Recurse -EA SilentlyContinue
   }
   if (Test-Path -Path "\$islandServiceDataPath") {
           Remove-Item -Path "\$islandServiceDataPath" -Force -Recurse -EA SilentlyContinue
   }

   try {
     \$product = Get-WmiObject -Class Win32_Product -Filter "Name = 'IslandBackgroundService'" -ErrorAction Stop
       if (-not \$product) {
         Write-Warning "Product IslandBackgroundService not found. Exiting."
         return
       }
   }
   catch {
     Write-Warning "No product found with name \$ProductName. Exiting."
     return
   }

   \$productCode = \$product.IdentifyingNumber
   Write-Host "Found Product Code (GUID): \$productCode"

   function ConvertTo-RegistryReversedGuid {
     param(
         [Parameter(Mandatory = \$true)]
         [ValidatePattern('^\\{[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}\\}\$')]
         [string]\$Guid
     )

     \$guidStruct = [System.Guid]\$Guid
     \$byteArray  = \$guidStruct.ToByteArray()
     \$hexBytes   = \$byteArray | ForEach-Object { \$_.ToString("X2") }
     return (\$hexBytes -join '')
   }

   Write-Host "Reversed registry GUID: \$reversedGuid"

   \$registryPaths = @(
     "HKLM:\\SOFTWARE\\Classes\\Installer\\Products\\\$reversedGuid",
     "HKCR:\\Installer\\Products\\\$reversedGuid",
     "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Installer\\UserData\\S-1-5-18\\Products\\\$reversedGuid\\InstallProperties",
     "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\{\$guidNoBraces}",
     "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\$guidNoBraces"
   )

   foreach (\$path in \$registryPaths) {
     Write-Host "Removing: \$path"
     try {
         Remove-Item -Path \$path -Recurse -Force -ErrorAction Stop
         Write-Host "SUCCESS: \$path removed."
     } catch {
         Write-Warning "Could not remove or key not found: \$path"
     }
   }

   Write-Host "`n[DONE] Registry cleanup for '\$ProductName' complete."
} catch {
    Write-Host "An error occurred while trying to uninstall service:"
    Write-Host \$_
}