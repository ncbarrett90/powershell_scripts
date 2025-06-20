# Python Installation Check and Install Script
# Requires elevated privileges for installation

param(
    [string]$PythonVersion = "3.12.0",
    [switch]$Force = $false
)

Write-Host "Python Installation Checker" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

function Test-PythonInstalled {
    try {
        $pythonVersion = python --version 2>$null
        if ($pythonVersion) {
            Write-Host "Python found: $pythonVersion" -ForegroundColor Green
            return $true
        }
    } catch {
        # Python not found in PATH
    }
    
    # Also check python3 command
    try {
        $python3Version = python3 --version 2>$null
        if ($python3Version) {
            Write-Host "Python found: $python3Version" -ForegroundColor Green
            return $true
        }
    } catch {
        # Python3 not found in PATH
    }
    
    Write-Host "Python not found in PATH" -ForegroundColor Yellow
    return $false
}

function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-PythonFromWeb {
    param([string]$Version)
    
    Write-Host "Downloading Python $Version..." -ForegroundColor Yellow
    
    # Determine architecture
    $architecture = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "win32" }
    
    # Construct download URL
    $downloadUrl = "https://www.python.org/ftp/python/$Version/python-$Version-$architecture.exe"
    $installerPath = "$env:TEMP\python-$Version-installer.exe"
    
    try {
        # Download installer
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing
        Write-Host "Download completed." -ForegroundColor Green
        
        # Install Python silently
        Write-Host "Installing Python..." -ForegroundColor Yellow
        $installArgs = @(
            "/quiet",
            "InstallAllUsers=1",
            "PrependPath=1",
            "Include_test=0"
        )
        
        $process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "Python installation completed successfully!" -ForegroundColor Green
            
            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            # Clean up installer
            Remove-Item $installerPath -Force
            return $true
        } else {
            Write-Host "Installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
            return $false
        }
        
    } catch {
        Write-Host "Error during installation: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-PythonWithWinget {
    try {
        # Check if winget is available
        $wingetVersion = winget --version 2>$null
        if (-not $wingetVersion) {
            Write-Host "Winget not available, falling back to web installer..." -ForegroundColor Yellow
            return $false
        }
        
        Write-Host "Installing Python using winget..." -ForegroundColor Yellow
        $process = Start-Process -FilePath "winget" -ArgumentList "install", "Python.Python.3.12", "--silent", "--accept-package-agreements", "--accept-source-agreements" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "Python installed successfully via winget!" -ForegroundColor Green
            
            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            return $true
        } else {
            Write-Host "Winget installation failed, trying web installer..." -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "Winget installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

# Main script execution
if (-not $Force -and (Test-PythonInstalled)) {
    Write-Host "Python is already installed. Use -Force to reinstall." -ForegroundColor Green
    exit 0
}

if (-not (Test-AdminPrivileges)) {
    Write-Host "This script requires administrator privileges to install Python." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
    
    # Attempt to restart as admin
    $response = Read-Host "Would you like to restart this script as Administrator? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        $arguments = "-File `"$($MyInvocation.MyCommand.Path)`""
        if ($Force) { $arguments += " -Force" }
        Start-Process powershell -ArgumentList $arguments -Verb RunAs
    }
    exit 1
}

Write-Host "Starting Python installation process..." -ForegroundColor Yellow

# Try winget first (faster and cleaner), then fall back to web installer
$installSuccess = Install-PythonWithWinget

if (-not $installSuccess) {
    Write-Host "Trying direct web installation..." -ForegroundColor Yellow
    $installSuccess = Install-PythonFromWeb -Version $PythonVersion
}

if ($installSuccess) {
    Write-Host "`nVerifying installation..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3  # Give time for PATH to update
    
    if (Test-PythonInstalled) {
        Write-Host "`nInstallation verification successful!" -ForegroundColor Green
        Write-Host "You can now use 'python' command from any command prompt." -ForegroundColor Green
    } else {
        Write-Host "`nInstallation completed but Python not found in PATH." -ForegroundColor Yellow
        Write-Host "You may need to restart your command prompt or computer." -ForegroundColor Yellow
    }
} else {
    Write-Host "`nFailed to install Python. Please try manual installation from python.org" -ForegroundColor Red
    exit 1
}

Write-Host "`nScript completed." -ForegroundColor Green
