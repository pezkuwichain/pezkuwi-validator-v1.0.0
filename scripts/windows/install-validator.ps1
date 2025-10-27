# Pezkuwi Validator Installer for Windows
# Usage: iwr -useb https://raw.githubusercontent.com/pezkuwichain/pezkuwi-validator-v1.0.0/main/scripts/windows/install-validator.ps1 | iex

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "🚀 Pezkuwi Validator Installer v1.0.0 (Windows)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$PEZKUWI_VERSION = "v1.0.0-local-testnet-success"
$GITHUB_REPO = "pezkuwichain/pezkuwi-sdk"
$INSTALL_DIR = "$env:USERPROFILE\.pezkuwi"
$CHAIN_SPEC_URL = "https://raw.githubusercontent.com/$GITHUB_REPO/main/pezkuwi-local-raw.json"

# Functions
function Write-Success {
    param($Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param($Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param($Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

function Check-Requirements {
    Write-Info "Checking system requirements..."
    
    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Write-Error-Custom "Windows 10 or later required"
        exit 1
    }
    
    # Check CPU cores
    $cpuCores = (Get-WmiObject Win32_Processor).NumberOfLogicalProcessors
    if ($cpuCores -lt 2) {
        Write-Error-Custom "Minimum 2 CPU cores required (found: $cpuCores)"
        exit 1
    }
    
    # Check RAM
    $totalRAM = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    if ($totalRAM -lt 4) {
        Write-Error-Custom "Minimum 4GB RAM required (found: ${totalRAM}GB)"
        exit 1
    }
    
    Write-Success "System requirements met"
}

function Install-Dependencies {
    Write-Info "Checking dependencies..."
    
    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Info "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    
    Write-Success "Dependencies ready"
}

function Download-Binaries {
    Write-Info "Downloading Pezkuwi binaries..."
    
    New-Item -ItemType Directory -Force -Path "$INSTALL_DIR\bin" | Out-Null
    
    $RELEASE_URL = "https://github.com/$GITHUB_REPO/releases/download/$PEZKUWI_VERSION"
    $ARCHIVE_NAME = "pezkuwi-binaries-linux-x86_64.tar.gz"
    $TEMP_FILE = "$env:TEMP\$ARCHIVE_NAME"
    
    try {
        # Download archive
        Write-Info "Downloading from: $RELEASE_URL/$ARCHIVE_NAME"
        Invoke-WebRequest -Uri "$RELEASE_URL/$ARCHIVE_NAME" -OutFile $TEMP_FILE -UseBasicParsing
        
        # Extract using tar (available in Windows 10+)
        Write-Info "Extracting binaries..."
        tar -xzf $TEMP_FILE -C "$INSTALL_DIR\bin\"
        
        # Cleanup
        Remove-Item $TEMP_FILE
        
        Write-Success "Binaries downloaded and extracted"
    }
    catch {
        Write-Error-Custom "Failed to download binaries: $_"
        Write-Info "Please check if release exists: $RELEASE_URL"
        exit 1
    }
}

function Download-ChainSpec {
    Write-Info "Downloading chain specification..."
    
    New-Item -ItemType Directory -Force -Path "$INSTALL_DIR\config" | Out-Null
    
    try {
        Invoke-WebRequest -Uri $CHAIN_SPEC_URL -OutFile "$INSTALL_DIR\config\chain-spec.json" -UseBasicParsing
        Write-Success "Chain spec downloaded"
    }
    catch {
        Write-Error-Custom "Failed to download chain spec: $_"
        exit 1
    }
}

function Generate-Keys {
    Write-Info "Generating validator keys..."
    
    New-Item -ItemType Directory -Force -Path "$INSTALL_DIR\keys" | Out-Null
    
    $nodeKeyOutput = & "$INSTALL_DIR\bin\pezkuwi.exe" key generate-node-key --base-path "$INSTALL_DIR\data" --chain "$INSTALL_DIR\config\chain-spec.json" 2>&1
    $nodeKeyOutput | Out-File "$INSTALL_DIR\keys\node-id.txt"
    
    $nodeId = Get-Content "$INSTALL_DIR\keys\node-id.txt"
    
    Write-Success "Keys generated"
    Write-Info "Your Node ID: $nodeId"
}

function Create-WindowsService {
    Write-Info "Creating Windows service..."
    
    $serviceName = "PezkuwiValidator"
    $displayName = "Pezkuwi Validator Node"
    $description = "Pezkuwi blockchain validator node"
    
    # Remove existing service if present
    $existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($existingService) {
        Write-Info "Removing existing service..."
        Stop-Service -Name $serviceName -Force
        sc.exe delete $serviceName
        Start-Sleep -Seconds 2
    }
    
    # Create batch file to run the validator
    $batchFile = "$INSTALL_DIR\start-validator.bat"
    @"
@echo off
cd /d "$INSTALL_DIR"
"$INSTALL_DIR\bin\pezkuwi.exe" --chain "$INSTALL_DIR\config\chain-spec.json" --base-path "$INSTALL_DIR\data" --validator --name "Validator-$env:COMPUTERNAME" --port 30333 --rpc-port 9944 --rpc-cors all --rpc-methods=unsafe
"@ | Out-File -FilePath $batchFile -Encoding ASCII
    
    # Create service using NSSM (Non-Sucking Service Manager)
    choco install nssm -y --no-progress
    
    nssm install $serviceName "$batchFile"
    nssm set $serviceName DisplayName $displayName
    nssm set $serviceName Description $description
    nssm set $serviceName Start SERVICE_AUTO_START
    
    Write-Success "Windows service created"
}

function Start-Validator {
    Write-Info "Starting validator..."
    
    Start-Service -Name "PezkuwiValidator"
    Start-Sleep -Seconds 3
    
    $service = Get-Service -Name "PezkuwiValidator"
    if ($service.Status -eq "Running") {
        Write-Success "Validator started successfully!"
    }
    else {
        Write-Error-Custom "Failed to start validator"
        Write-Info "Check logs in Event Viewer"
        exit 1
    }
}

function Print-Summary {
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "🎉 Installation Complete!" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📍 Install Directory: $INSTALL_DIR"
    Write-Host "🔑 Node ID: $(Get-Content $INSTALL_DIR\keys\node-id.txt)"
    Write-Host ""
    Write-Host "📊 Useful Commands:" -ForegroundColor Yellow
    Write-Host "  • Check status:  Get-Service PezkuwiValidator"
    Write-Host "  • View logs:     Get-EventLog -LogName Application -Source PezkuwiValidator -Newest 50"
    Write-Host "  • Stop node:     Stop-Service PezkuwiValidator"
    Write-Host "  • Restart node:  Restart-Service PezkuwiValidator"
    Write-Host ""
    Write-Host "🌐 RPC Endpoint: http://localhost:9944"
    Write-Host "📡 P2P Port: 30333"
    Write-Host ""
}

# Main execution
try {
    Check-Requirements
    Install-Dependencies
    Download-Binaries
    Download-ChainSpec
    Generate-Keys
    Create-WindowsService
    Start-Validator
    Print-Summary
}
catch {
    Write-Error-Custom "Installation failed: $_"
    exit 1
}
