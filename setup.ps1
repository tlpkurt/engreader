# Engreader - Full Setup Script
# This script installs all required dependencies

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Engreader - Automated Setup Script  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  This script requires Administrator privileges!" -ForegroundColor Yellow
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Right-click PowerShell -> Run as Administrator" -ForegroundColor White
    pause
    exit
}

# Function to check if a command exists
function Test-Command {
    param($Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Function to check if a service is running
function Test-ServiceRunning {
    param($ServiceName)
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    return ($null -ne $service -and $service.Status -eq 'Running')
}

Write-Host "📋 Checking system requirements..." -ForegroundColor Yellow
Write-Host ""

# 1. Check Chocolatey
Write-Host "1️⃣  Checking Chocolatey package manager..." -ForegroundColor Cyan
if (-not (Test-Command choco)) {
    Write-Host "   ❌ Chocolatey not found. Installing..." -ForegroundColor Red
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "   ✅ Chocolatey installed!" -ForegroundColor Green
} else {
    Write-Host "   ✅ Chocolatey already installed" -ForegroundColor Green
}
Write-Host ""

# 2. Check .NET SDK
Write-Host "2️⃣  Checking .NET 8 SDK..." -ForegroundColor Cyan
if (Test-Command dotnet) {
    $dotnetVersion = dotnet --version
    Write-Host "   ✅ .NET SDK $dotnetVersion already installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ .NET SDK not found. Installing..." -ForegroundColor Red
    choco install dotnet-sdk -y
    Write-Host "   ✅ .NET SDK installed!" -ForegroundColor Green
}
Write-Host ""

# 3. Check PostgreSQL
Write-Host "3️⃣  Checking PostgreSQL 16..." -ForegroundColor Cyan
if (Test-Command psql) {
    Write-Host "   ✅ PostgreSQL already installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ PostgreSQL not found. Installing..." -ForegroundColor Red
    choco install postgresql16 --params '/Password:postgres' -y
    Write-Host "   ✅ PostgreSQL installed!" -ForegroundColor Green
    Write-Host "   ℹ️  Default password: postgres" -ForegroundColor Yellow
}

# Start PostgreSQL service
$pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pgService) {
    if ($pgService.Status -ne 'Running') {
        Write-Host "   🔄 Starting PostgreSQL service..." -ForegroundColor Yellow
        Start-Service $pgService.Name
        Write-Host "   ✅ PostgreSQL service started!" -ForegroundColor Green
    } else {
        Write-Host "   ✅ PostgreSQL service already running" -ForegroundColor Green
    }
}
Write-Host ""

# 4. Install pgvector extension
Write-Host "4️⃣  Setting up pgvector extension..." -ForegroundColor Cyan
$pgBinPath = "C:\Program Files\PostgreSQL\16\bin"
if (Test-Path $pgBinPath) {
    $env:Path = "$pgBinPath;$env:Path"
    
    # Create database if not exists
    Write-Host "   🔄 Creating engreader database..." -ForegroundColor Yellow
    $env:PGPASSWORD = "postgres"
    & "$pgBinPath\psql.exe" -U postgres -c "CREATE DATABASE engreader;" 2>$null
    
    # Install pgvector extension
    Write-Host "   🔄 Installing pgvector extension..." -ForegroundColor Yellow
    & "$pgBinPath\psql.exe" -U postgres -d engreader -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>$null
    Write-Host "   ✅ Database and pgvector ready!" -ForegroundColor Green
}
Write-Host ""

# 5. Check Redis
Write-Host "5️⃣  Checking Redis..." -ForegroundColor Cyan
if (Test-Command redis-server) {
    Write-Host "   ✅ Redis already installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ Redis not found. Installing..." -ForegroundColor Red
    choco install redis-64 -y
    Write-Host "   ✅ Redis installed!" -ForegroundColor Green
}

# Start Redis service
$redisService = Get-Service -Name "Redis" -ErrorAction SilentlyContinue
if ($redisService) {
    if ($redisService.Status -ne 'Running') {
        Write-Host "   🔄 Starting Redis service..." -ForegroundColor Yellow
        Start-Service Redis
        Write-Host "   ✅ Redis service started!" -ForegroundColor Green
    } else {
        Write-Host "   ✅ Redis service already running" -ForegroundColor Green
    }
}
Write-Host ""

# 6. Check Git
Write-Host "6️⃣  Checking Git..." -ForegroundColor Cyan
if (Test-Command git) {
    $gitVersion = git --version
    Write-Host "   ✅ $gitVersion already installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ Git not found. Installing..." -ForegroundColor Red
    choco install git -y
    Write-Host "   ✅ Git installed!" -ForegroundColor Green
}
Write-Host ""

# 7. Check Node.js (for Flutter web development)
Write-Host "7️⃣  Checking Node.js..." -ForegroundColor Cyan
if (Test-Command node) {
    $nodeVersion = node --version
    Write-Host "   ✅ Node.js $nodeVersion already installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ Node.js not found. Installing..." -ForegroundColor Red
    choco install nodejs-lts -y
    Write-Host "   ✅ Node.js installed!" -ForegroundColor Green
}
Write-Host ""

# 8. Check Flutter (optional but recommended)
Write-Host "8️⃣  Checking Flutter..." -ForegroundColor Cyan
if (Test-Command flutter) {
    $flutterVersion = flutter --version | Select-Object -First 1
    Write-Host "   ✅ Flutter already installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ Flutter not found. Installing..." -ForegroundColor Red
    Write-Host "   ℹ️  This may take 5-10 minutes..." -ForegroundColor Yellow
    choco install flutter -y
    Write-Host "   ✅ Flutter installed!" -ForegroundColor Green
    Write-Host "   ℹ️  Close and reopen terminal to use Flutter" -ForegroundColor Yellow
}
Write-Host ""

# 9. Install EF Core tools
Write-Host "9️⃣  Checking EF Core tools..." -ForegroundColor Cyan
$efToolPath = "$PSScriptRoot\backend\tools\dotnet-ef.exe"
if (Test-Path $efToolPath) {
    Write-Host "   ✅ EF Core tools already installed" -ForegroundColor Green
} else {
    Write-Host "   🔄 Installing EF Core tools..." -ForegroundColor Yellow
    cd "$PSScriptRoot\backend"
    dotnet tool install --tool-path ./tools dotnet-ef
    Write-Host "   ✅ EF Core tools installed!" -ForegroundColor Green
}
Write-Host ""

# 10. Run database migrations
Write-Host "🔟 Running database migrations..." -ForegroundColor Cyan
cd "$PSScriptRoot\backend"
$env:PGPASSWORD = "postgres"
.\tools\dotnet-ef.exe database update --project Engreader.Api --context EngreaderDbContext --connection "Host=localhost;Port=5432;Database=engreader;Username=postgres;Password=postgres"
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Database migrations completed!" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Database migration failed. Will try again when backend starts." -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         🎉 Setup Complete! 🎉         " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Installed Components:" -ForegroundColor Green
Write-Host "   • .NET 8 SDK" -ForegroundColor White
Write-Host "   • PostgreSQL 16 + pgvector" -ForegroundColor White
Write-Host "   • Redis" -ForegroundColor White
Write-Host "   • Git" -ForegroundColor White
Write-Host "   • Node.js" -ForegroundColor White
Write-Host "   • Flutter (if not already installed)" -ForegroundColor White
Write-Host "   • EF Core Tools" -ForegroundColor White
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Update OpenAI API Key:" -ForegroundColor Cyan
Write-Host "   Edit: backend\.env" -ForegroundColor White
Write-Host "   Set: OPENAI_API_KEY=your-api-key-here" -ForegroundColor White
Write-Host ""
Write-Host "2. Start Backend API:" -ForegroundColor Cyan
Write-Host "   cd backend" -ForegroundColor White
Write-Host "   .\start-backend.ps1" -ForegroundColor White
Write-Host ""
Write-Host "3. Start Flutter App (after backend is running):" -ForegroundColor Cyan
Write-Host "   cd flutter\engreader_app" -ForegroundColor White
Write-Host "   flutter pub get" -ForegroundColor White
Write-Host "   dart run build_runner build --delete-conflicting-outputs" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor White
Write-Host ""
Write-Host "4. Access API Documentation:" -ForegroundColor Cyan
Write-Host "   http://localhost:5000/swagger" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Important: Close and reopen your terminal to use Flutter!" -ForegroundColor Yellow
Write-Host ""
pause
