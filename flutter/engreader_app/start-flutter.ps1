# Start Flutter App

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    Starting Engreader Flutter App     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter is not installed or not in PATH!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Flutter first:" -ForegroundColor Yellow
    Write-Host "1. Run setup.ps1 in the root directory" -ForegroundColor White
    Write-Host "2. Or visit: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor White
    pause
    exit
}

# Check backend
Write-Host "🔍 Checking Backend API..." -ForegroundColor Yellow
$backendTest = Test-NetConnection -ComputerName localhost -Port 5000 -InformationLevel Quiet -WarningAction SilentlyContinue
if (-not $backendTest) {
    Write-Host "⚠️  Backend API is not running!" -ForegroundColor Yellow
    Write-Host "Please start backend first:" -ForegroundColor Yellow
    Write-Host "   cd ..\..\backend" -ForegroundColor White
    Write-Host "   .\start-backend.ps1" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit
    }
} else {
    Write-Host "✅ Backend API is running" -ForegroundColor Green
}
Write-Host ""

# Get packages
Write-Host "📦 Getting Flutter packages..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get packages!" -ForegroundColor Red
    pause
    exit
}
Write-Host "✅ Packages downloaded" -ForegroundColor Green
Write-Host ""

# Check if code generation is needed
$needsCodegen = $false
if (-not (Test-Path "lib\features\auth\data\models\user_model.freezed.dart")) {
    $needsCodegen = $true
}

if ($needsCodegen) {
    Write-Host "🔨 Running code generation..." -ForegroundColor Yellow
    Write-Host "   This may take 30-60 seconds..." -ForegroundColor White
    dart run build_runner build --delete-conflicting-outputs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Code generation failed!" -ForegroundColor Red
        pause
        exit
    }
    Write-Host "✅ Code generation completed" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "✅ Code already generated, skipping..." -ForegroundColor Green
    Write-Host ""
}

# Analyze code
Write-Host "🔍 Analyzing code..." -ForegroundColor Yellow
flutter analyze --no-fatal-infos
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Code analysis found issues, but continuing..." -ForegroundColor Yellow
}
Write-Host ""

# Start app
Write-Host "========================================" -ForegroundColor Green
Write-Host "🚀 Starting Flutter App..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Press 'r' to hot reload" -ForegroundColor Cyan
Write-Host "Press 'R' to hot restart" -ForegroundColor Cyan
Write-Host "Press 'q' to quit" -ForegroundColor Cyan
Write-Host ""

flutter run
