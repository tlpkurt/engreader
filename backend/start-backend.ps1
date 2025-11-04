Write-Host "Starting Engreader Backend API..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Restoring NuGet packages..." -ForegroundColor Yellow
dotnet restore

Write-Host "Building project..." -ForegroundColor Yellow
dotnet build src/Engreader.Api/Engreader.Api.csproj --configuration Debug

Write-Host ""
Write-Host "Starting API Server..." -ForegroundColor Green
Write-Host "API URL: http://localhost:5000" -ForegroundColor Cyan
Write-Host "Swagger: http://localhost:5000/swagger" -ForegroundColor Cyan
Write-Host ""

$env:ASPNETCORE_ENVIRONMENT = "Development"
dotnet run --project src/Engreader.Api/Engreader.Api.csproj
