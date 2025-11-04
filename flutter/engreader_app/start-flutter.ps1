# Start Flutter App# Start Flutter App

Write-Host "========================================" -ForegroundColor CyanWrite-Host "========================================" -ForegroundColor Cyan

Write-Host "    Starting Engreader Flutter App     " -ForegroundColor CyanWrite-Host "    Starting Engreader Flutter App     " -ForegroundColor Cyan

Write-Host "========================================" -ForegroundColor CyanWrite-Host "========================================" -ForegroundColor Cyan

Write-Host ""Write-Host ""



# Check if Flutter is installed# Check if Flutter is installed

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {

    Write-Host "[X] Flutter is not installed or not in PATH!" -ForegroundColor Red    Write-Host "❌ Flutter is not installed or not in PATH!" -ForegroundColor Red

    Write-Host ""    Write-Host ""

    Write-Host "Please install Flutter first:" -ForegroundColor Yellow    Write-Host "Please install Flutter first:" -ForegroundColor Yellow

    Write-Host "1. Run setup.ps1 in the root directory" -ForegroundColor White    Write-Host "1. Run setup.ps1 in the root directory" -ForegroundColor White

    Write-Host "2. Or visit: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor White    Write-Host "2. Or visit: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor White

    pause    pause

    exit    exit

}}



# Check backend

Write-Host "[*] Checking Backend API..." -ForegroundColor Yellow

$backendTest = Test-NetConnection -ComputerName localhost -Port 5000 -InformationLevel Quiet -WarningAction SilentlyContinue

if (-not $backendTest) {# Check backend

    Write-Host "[!] Backend API is not running!" -ForegroundColor YellowWrite-Host "🔍 Checking Backend API..." -ForegroundColor Yellow

    Write-Host "Please start backend first:" -ForegroundColor Yellow$backendTest = Test-NetConnection -ComputerName localhost -Port 5000 -InformationLevel Quiet -WarningAction SilentlyContinue

    Write-Host "   cd ..\..\backend" -ForegroundColor Whiteif (-not $backendTest) {

    Write-Host "   .\start-backend.ps1" -ForegroundColor White    Write-Host "⚠️  Backend API is not running!" -ForegroundColor Yellow

    Write-Host ""    Write-Host "Please start backend first:" -ForegroundColor Yellow

    $continue = Read-Host "Continue anyway? (y/n)"    Write-Host "   cd ..\..\backend" -ForegroundColor White

    if ($continue -ne "y") {    Write-Host "   .\start-backend.ps1" -ForegroundColor White

        exit    Write-Host ""

    }    $continue = Read-Host "Continue anyway? (y/n)"

} else {    if ($continue -ne "y") {

    Write-Host "[OK] Backend API is running" -ForegroundColor Green        exit

}    }

Write-Host ""} else {

    Write-Host "✅ Backend API is running" -ForegroundColor Green

# Get packages}

Write-Host "[*] Getting Flutter packages..." -ForegroundColor YellowWrite-Host ""

flutter pub get

if ($LASTEXITCODE -ne 0) {

    Write-Host "[X] Failed to get packages!" -ForegroundColor Red

    pause

    exit# Get packages

}Write-Host "📦 Getting Flutter packages..." -ForegroundColor Yellow

Write-Host "[OK] Packages downloaded" -ForegroundColor Greenflutter pub get

Write-Host ""if ($LASTEXITCODE -ne 0) {

    Write-Host "❌ Failed to get packages!" -ForegroundColor Red

# Check if code generation is needed    pause

$needsCodegen = $false    exit

if (-not (Test-Path "lib\features\auth\data\models\user_model.freezed.dart")) {}

    $needsCodegen = $trueWrite-Host "✅ Packages downloaded" -ForegroundColor Green

}Write-Host ""



if ($needsCodegen) {

    Write-Host "[*] Running code generation..." -ForegroundColor Yellow

    Write-Host "   This may take 30-60 seconds..." -ForegroundColor White

    dart run build_runner build --delete-conflicting-outputs# Check if code generation is needed

    if ($LASTEXITCODE -ne 0) {$needsCodegen = $false

        Write-Host "[X] Code generation failed!" -ForegroundColor Redif (-not (Test-Path "lib\features\auth\data\models\user_model.freezed.dart")) {

        pause    $needsCodegen = $true

        exit}

    }

    Write-Host "[OK] Code generation completed" -ForegroundColor Greenif ($needsCodegen) {

    Write-Host ""    Write-Host "[*] Running code generation..." -ForegroundColor Yellow

} else {    Write-Host "   This may take 30-60 seconds..." -ForegroundColor White

    Write-Host "[OK] Code already generated, skipping..." -ForegroundColor Green    dart run build_runner build --delete-conflicting-outputs

    Write-Host ""    if ($LASTEXITCODE -ne 0) {

}        Write-Host "[X] Code generation failed!" -ForegroundColor Red

        pause

# Analyze code        exit

Write-Host "[*] Analyzing code..." -ForegroundColor Yellow    }

flutter analyze --no-fatal-infos    Write-Host "[OK] Code generation completed" -ForegroundColor Green

if ($LASTEXITCODE -ne 0) {    Write-Host ""

    Write-Host "[!] Code analysis found issues, but continuing..." -ForegroundColor Yellow} else {

}    Write-Host "[OK] Code already generated, skipping..." -ForegroundColor Green

Write-Host ""    Write-Host ""

}

# Start app

Write-Host "========================================" -ForegroundColor Green

Write-Host "[*] Starting Flutter App on Windows..." -ForegroundColor Green

Write-Host "========================================" -ForegroundColor Green

Write-Host ""# Analyze code

Write-Host "Press r to hot reload" -ForegroundColor CyanWrite-Host "🔍 Analyzing code..." -ForegroundColor Yellow

Write-Host "Press R to hot restart" -ForegroundColor Cyanflutter analyze --no-fatal-infos

Write-Host "Press q to quit" -ForegroundColor Cyanif ($LASTEXITCODE -ne 0) {

Write-Host ""    Write-Host "⚠️  Code analysis found issues, but continuing..." -ForegroundColor Yellow

}

flutter run -d windowsWrite-Host ""


# Start app
Write-Host "========================================" -ForegroundColor Green
Write-Host "[*] Starting Flutter App on Chrome..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Press r to hot reload" -ForegroundColor Cyan
Write-Host "Press R to hot restart" -ForegroundColor Cyan
Write-Host "Press q to quit" -ForegroundColor Cyan
Write-Host ""

flutter run -d chrome


