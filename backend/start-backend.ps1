# Start Backend API Server

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    Starting Engreader Backend API     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  .env file not found!" -ForegroundColor Yellow
    Write-Host "Creating from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ .env file created!" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Edit .env and add your OpenAI API key!" -ForegroundColor Yellow
    Write-Host "   Set: OPENAI_API_KEY=your-api-key-here" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Continue without OpenAI key? (y/n)"
    if ($continue -ne "y") {
        exit
    }
}

# Check PostgreSQL
Write-Host "🔍 Checking PostgreSQL..." -ForegroundColor Yellow
$pgTest = Test-NetConnection -ComputerName localhost -Port 5432 -InformationLevel Quiet -WarningAction SilentlyContinue
if (-not $pgTest) {
    Write-Host "❌ PostgreSQL is not running!" -ForegroundColor Red
    Write-Host "Please start PostgreSQL service first." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try: Start-Service postgresql-x64-16" -ForegroundColor White
    pause
    exit
}
Write-Host "✅ PostgreSQL is running" -ForegroundColor Green
Write-Host ""

# Check Redis
Write-Host "🔍 Checking Redis..." -ForegroundColor Yellow
$redisTest = Test-NetConnection -ComputerName localhost -Port 6379 -InformationLevel Quiet -WarningAction SilentlyContinue
if (-not $redisTest) {
    Write-Host "⚠️  Redis is not running!" -ForegroundColor Yellow
    Write-Host "Translation caching will not work." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue without Redis? (y/n)"
    if ($continue -ne "y") {
        exit
    }
} else {
    Write-Host "✅ Redis is running" -ForegroundColor Green
}
Write-Host ""

# Restore packages
Write-Host "📦 Restoring NuGet packages..." -ForegroundColor Yellow
dotnet restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to restore packages!" -ForegroundColor Red
    pause
    exit
}
Write-Host "✅ Packages restored" -ForegroundColor Green
Write-Host ""

# Run migrations
Write-Host "🗄️  Running database migrations..." -ForegroundColor Yellow
if (Test-Path "tools\dotnet-ef.exe") {
    .\tools\dotnet-ef.exe database update --project Engreader.Api --context EngreaderDbContext
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database migrations completed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Migration failed, but continuing..." -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  EF tools not found, skipping migrations" -ForegroundColor Yellow
}
Write-Host ""

# Build project
Write-Host "🔨 Building project..." -ForegroundColor Yellow
dotnet build Engreader.Api/Engreader.Api.csproj --configuration Debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    pause
    exit
}
Write-Host "✅ Build successful" -ForegroundColor Green
Write-Host ""

# Start server
Write-Host "========================================" -ForegroundColor Green
Write-Host "🚀 Starting API Server..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📍 API URL: http://localhost:5000" -ForegroundColor Cyan
Write-Host "📚 Swagger: http://localhost:5000/swagger" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

dotnet run --project Engreader.Api/Engreader.Api.csproj
