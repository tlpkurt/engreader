# Install Flutter - Quick Setup Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    Installing Flutter SDK             " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    pause
    exit
}

# Install Chocolatey if not present
Write-Host "1️⃣  Checking Chocolatey..." -ForegroundColor Cyan
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "   Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh environment
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "   ✅ Chocolatey installed!" -ForegroundColor Green
} else {
    Write-Host "   ✅ Chocolatey already installed" -ForegroundColor Green
}
Write-Host ""

# Install Git (Flutter dependency)
Write-Host "2️⃣  Checking Git..." -ForegroundColor Cyan
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "   Installing Git..." -ForegroundColor Yellow
    choco install git -y
    Write-Host "   ✅ Git installed!" -ForegroundColor Green
} else {
    Write-Host "   ✅ Git already installed" -ForegroundColor Green
}
Write-Host ""

# Install Flutter
Write-Host "3️⃣  Installing Flutter SDK..." -ForegroundColor Cyan
Write-Host "   ⏳ This may take 5-10 minutes..." -ForegroundColor Yellow
choco install flutter -y

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Flutter installed successfully!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Flutter installation failed!" -ForegroundColor Red
    pause
    exit
}
Write-Host ""

# Refresh environment variables
Write-Host "4️⃣  Refreshing environment..." -ForegroundColor Cyan
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Write-Host "   ✅ Environment refreshed" -ForegroundColor Green
Write-Host ""

# Run Flutter doctor
Write-Host "5️⃣  Running Flutter doctor..." -ForegroundColor Cyan
flutter doctor

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "    ✅ Flutter Setup Complete!          " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  IMPORTANT: Close and reopen ALL terminal windows to use Flutter!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Close this terminal" -ForegroundColor White
Write-Host "2. Open a new terminal" -ForegroundColor White
Write-Host "3. Run: flutter doctor" -ForegroundColor White
Write-Host "4. cd flutter\engreader_app" -ForegroundColor White
Write-Host "5. flutter pub get" -ForegroundColor White
Write-Host "6. flutter run" -ForegroundColor White
Write-Host ""
pause
