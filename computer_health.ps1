# Script to use on all computers that come into the shop. Runs DISM, SFC, and Windows update
#### must run <Set-ExecutionPolicy RemoteSigned -Scope Process> to allow scripts to execute for the current process ####

# running DISM
Write-Host "Running DISM..."
DISM /Online /CleanUp-Image /RestoreHealth

# running SFC 
Write-Host "Running SFC..."
SFC /ScanNow

# install/import the PSWindowsUpdate module
Write-Host "Installing PSWindowsUpdate..."
Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

# update the computer 
Write-Host "Updating..."
Write-Host "The system may automatically restart to apply these updates..."
Get-WindowsUpdate -AcceptAll -Install -AutoReboot -Force

