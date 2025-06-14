# Script to update system firmware for Lenovo computers and update Windows using PSWindowsUpdate
#### must run <Set-ExecutionPolicy RemoteSigned -Scope Process> to allow scripts to execute for the current process ####

# install/import the modules needed for the script - PSWindowsUpdate and LSUclient 
Write-Host "Installing the LSUClient..."
Install-Module -Name LSUClient -Force

# check for the latest Lenovo firmware updates 
Write-Host "Downloading and installing Lenovo firmware updates..."
$updates = Get-LSUpdate
$updates | Install-LSUpdate -Verbose

# update the computer with PSWindowsUPdate
Write-Host "Updating..."
Write-Host "The system may automatically restart to apply these updates..."
Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -AutoReboot


