# 🚀 Deployment Rehberi - Engreader

## Deployment Stratejisi

Bu doküman, Engreader uygulamasının production ortamına deploy edilmesi için gereken tüm adımları içerir.

---

## 📋 Deployment Seçenekleri

### Backend (.NET 8 API)
1. **Azure App Service** (Önerilen)
2. **AWS Elastic Beanstalk**
3. **Docker + Kubernetes**
4. **VPS (DigitalOcean, Linode)**

### Database (PostgreSQL + pgvector)
1. **Supabase** (Önerilen - pgvector built-in)
2. **Azure Database for PostgreSQL**
3. **AWS RDS PostgreSQL**
4. **Self-hosted VPS**

### Cache (Redis)
1. **Azure Cache for Redis** (Önerilen)
2. **AWS ElastiCache**
3. **Redis Cloud**
4. **Self-hosted**

### Flutter App
1. **Google Play Store** (Android)
2. **Apple App Store** (iOS)
3. **Web Hosting** (Firebase Hosting, Netlify, Vercel)

---

## 🎯 Deployment Roadmap

### Phase 1: Backend Preparation (Day 1-2)
- ✅ Environment variables setup
- ✅ Production connection strings
- ✅ CORS configuration
- ✅ Logging setup
- ✅ Health checks
- ✅ API versioning

### Phase 2: Database Setup (Day 2-3)
- ✅ Production database creation
- ✅ Migration execution
- ✅ Backup strategy
- ✅ Connection pooling
- ✅ Performance tuning

### Phase 3: Backend Deployment (Day 3-4)
- ✅ CI/CD pipeline setup
- ✅ SSL certificate
- ✅ Domain configuration
- ✅ Load testing
- ✅ Monitoring setup

### Phase 4: Flutter App Build (Day 5-6)
- ✅ Production config
- ✅ API URL update
- ✅ App signing
- ✅ Build APK/IPA
- ✅ Testing on real devices

### Phase 5: App Store Submission (Day 7-14)
- ✅ Store listings
- ✅ Screenshots
- ✅ Privacy policy
- ✅ Terms of service
- ✅ Review process

**Total Estimated Time:** 2 weeks

---

## 🔧 PHASE 1: Backend Preparation

### 1.1 Environment Variables Setup

**Oluştur:** `Engreader.Api/appsettings.Production.json`

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Host=YOUR_DB_HOST;Port=5432;Database=engreader_prod;Username=YOUR_DB_USER;Password=YOUR_DB_PASSWORD;SSL Mode=Require;Trust Server Certificate=true",
    "Redis": "YOUR_REDIS_CONNECTION_STRING"
  },
  "JwtSettings": {
    "Secret": "YOUR_SUPER_SECRET_256_BIT_KEY_CHANGE_THIS_IN_PRODUCTION_MINIMUM_32_CHARACTERS",
    "Issuer": "https://api.engreader.com",
    "Audience": "https://engreader.com",
    "AccessTokenExpirationMinutes": 60,
    "RefreshTokenExpirationDays": 7
  },
  "OpenAI": {
    "ApiKey": "YOUR_OPENAI_API_KEY",
    "Model": "gpt-4o-mini",
    "MaxTokens": 1000,
    "Temperature": 0.7
  },
  "Cors": {
    "AllowedOrigins": [
      "https://engreader.com",
      "https://www.engreader.com",
      "https://app.engreader.com"
    ]
  }
}
```

**⚠️ GÜVENLİK ÖNEMLİ:**
- Asla production secrets'ı Git'e commit etme
- Environment variables veya Azure Key Vault kullan
- Secret rotation stratejisi belirle

---

### 1.2 CORS Configuration

**Düzenle:** `Engreader.Api/Program.cs`

```csharp
// CORS - Production için güncelle
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() 
    ?? new[] { "https://engreader.com" };

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(allowedOrigins)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials()
              .SetIsOriginAllowedToAllowWildcardSubdomains();
    });
});
```

---

### 1.3 Health Checks

**Ekle:** `Engreader.Api/Program.cs`

```csharp
using Microsoft.Extensions.Diagnostics.HealthChecks;

// Health checks ekle
builder.Services.AddHealthChecks()
    .AddNpgSql(
        builder.Configuration.GetConnectionString("DefaultConnection")!,
        name: "postgresql",
        failureStatus: HealthStatus.Unhealthy,
        tags: new[] { "db", "sql", "postgresql" })
    .AddRedis(
        builder.Configuration.GetConnectionString("Redis")!,
        name: "redis",
        failureStatus: HealthStatus.Unhealthy,
        tags: new[] { "cache", "redis" });

// ...

// Health check endpoint
app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var result = JsonSerializer.Serialize(new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                description = e.Value.Description,
                duration = e.Value.Duration.ToString()
            })
        });
        await context.Response.WriteAsync(result);
    }
});
```

**Test:**
```powershell
curl http://localhost:5000/health
```

---

### 1.4 Logging Setup (Serilog)

**Install:**
```powershell
cd C:\Users\tkurt\Desktop\engreader\backend\Engreader.Api
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
dotnet add package Serilog.Sinks.ApplicationInsights
```

**Ekle:** `Program.cs`

```csharp
using Serilog;

// Serilog configuration
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.EntityFrameworkCore", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "Engreader.Api")
    .WriteTo.Console()
    .WriteTo.File("logs/engreader-.txt", rollingInterval: RollingInterval.Day)
    .WriteTo.ApplicationInsights(
        builder.Configuration["ApplicationInsights:InstrumentationKey"]!,
        TelemetryConverter.Traces)
    .CreateLogger();

builder.Host.UseSerilog();

// ...

// Global exception handler
app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";

        var exceptionHandlerPathFeature =
            context.Features.Get<IExceptionHandlerPathFeature>();

        if (exceptionHandlerPathFeature?.Error != null)
        {
            Log.Error(exceptionHandlerPathFeature.Error, 
                "Unhandled exception occurred");

            await context.Response.WriteAsJsonAsync(new
            {
                error = "An unexpected error occurred",
                requestId = Activity.Current?.Id ?? context.TraceIdentifier
            });
        }
    });
});
```

---

### 1.5 API Versioning

**Install:**
```powershell
dotnet add package Asp.Versioning.Mvc
```

**Ekle:** `Program.cs`

```csharp
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
});
```

**Update Controllers:**
```csharp
[ApiController]
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/[controller]")]
public class AuthController : ControllerBase
{
    // ...
}
```

---

## 🗄️ PHASE 2: Database Setup

### 2.1 Supabase Setup (Önerilen)

**Neden Supabase?**
- ✅ PostgreSQL + pgvector built-in
- ✅ Free tier: 500 MB database
- ✅ Automatic backups
- ✅ Connection pooling
- ✅ Real-time subscriptions (future feature)

**Adımlar:**

1. **Supabase Hesabı Oluştur**
   - https://supabase.com adresine git
   - Sign up with GitHub
   - "New Project" oluştur
   - Project name: engreader-prod
   - Database password: Güçlü şifre seç (kaydet!)
   - Region: Europe (Frankfurt) - en yakın

2. **Connection String Al**
   - Settings → Database
   - Connection string'i kopyala:
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.xyzproject.supabase.co:5432/postgres
   ```

3. **pgvector Extension'ı Aktifleştir**
   - SQL Editor'e git
   - Çalıştır:
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```

4. **Migration Çalıştır**
   ```powershell
   cd C:\Users\tkurt\Desktop\engreader\backend
   
   # Connection string'i environment variable olarak ayarla
   $env:ConnectionStrings__DefaultConnection="Host=db.xyzproject.supabase.co;Port=5432;Database=postgres;Username=postgres;Password=YOUR_PASSWORD;SSL Mode=Require"
   
   # Migration çalıştır
   .\tools\dotnet-ef database update --project Engreader.Api --context EngreaderDbContext
   ```

5. **Database Schema Doğrula**
   - Supabase Table Editor'e git
   - Tables görünüyor mu?
   - 10 tablo: Users, Stories, Quizzes, QuizQuestions, QuizAttempts, QuizAnswers, Translations, Progress, ProgressEvents, RefreshTokens

---

### 2.2 Azure Database for PostgreSQL (Alternatif)

**Adımlar:**

1. **Azure Portal**
   - Azure Database for PostgreSQL flexible server oluştur
   - Server name: engreader-db
   - Region: West Europe
   - PostgreSQL version: 16
   - Compute + storage: Burstable, B1ms (1 vCore, 2 GiB RAM)

2. **pgvector Extension**
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```

3. **Firewall Rules**
   - Azure Portal → Networking
   - "Add current client IP address"
   - "Allow public access from any Azure service"

4. **Connection String**
   ```
   Host=engreader-db.postgres.database.azure.com;Port=5432;Database=engreader;Username=adminuser;Password=YOUR_PASSWORD;SSL Mode=Require
   ```

---

### 2.3 Database Backup Strategy

**Supabase (Automatic):**
- Daily backups (last 7 days) - included in free tier
- Point-in-time recovery - paid plans

**Manual Backup Script:**
```powershell
# backup.ps1
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "backup_$timestamp.sql"

$env:PGPASSWORD = "YOUR_DB_PASSWORD"

pg_dump -h db.xyzproject.supabase.co `
        -U postgres `
        -d postgres `
        -F c `
        -f $backupFile

Write-Host "Backup created: $backupFile"

# Upload to Azure Blob Storage or S3
```

**Scheduled Task (Windows):**
1. Task Scheduler aç
2. Create Basic Task
3. Name: "Engreader DB Backup"
4. Trigger: Daily, 2:00 AM
5. Action: Start a program
6. Program: `powershell.exe`
7. Arguments: `-File C:\backups\backup.ps1`

---

### 2.4 Database Performance Tuning

**Index Optimization:**
```sql
-- Sık kullanılan sorgular için index'ler
CREATE INDEX idx_stories_user_id ON "Stories"("UserId");
CREATE INDEX idx_stories_cefrLevel ON "Stories"("CefrLevel");
CREATE INDEX idx_stories_isCompleted ON "Stories"("IsCompleted");

CREATE INDEX idx_quizzes_story_id ON "Quizzes"("StoryId");
CREATE INDEX idx_quizattempts_user_id ON "QuizAttempts"("UserId");
CREATE INDEX idx_quizattempts_quiz_id ON "QuizAttempts"("QuizId");

CREATE INDEX idx_translations_user_id ON "Translations"("UserId");
CREATE INDEX idx_translations_story_id ON "Translations"("StoryId");

CREATE INDEX idx_progress_user_id ON "Progress"("UserId");
```

**Connection Pooling (Npgsql):**

**Ekle:** `appsettings.Production.json`
```json
"ConnectionStrings": {
  "DefaultConnection": "Host=...;Pooling=true;Minimum Pool Size=5;Maximum Pool Size=100;Connection Lifetime=300"
}
```

---

## 🚀 PHASE 3: Backend Deployment

### 3.1 Azure App Service Deployment (Önerilen)

#### 3.1.1 Azure Resource Oluştur

**Azure Portal:**
1. "Create a resource" → "Web App"
2. Basics:
   - Name: `engreader-api`
   - Publish: Code
   - Runtime stack: .NET 8 (LTS)
   - Operating System: Linux
   - Region: West Europe
   - Pricing plan: B1 (Basic)

3. Deployment:
   - GitHub Actions: Enable
   - GitHub account: Connect
   - Repository: engreader
   - Branch: main

4. Monitoring:
   - Application Insights: Enable
   - Region: Same as app

5. Review + create

#### 3.1.2 Configuration

**Azure Portal → Configuration → Application settings:**

```
Key                                              | Value
------------------------------------------------|-------
ASPNETCORE_ENVIRONMENT                          | Production
ConnectionStrings__DefaultConnection            | Host=db.xyzproject.supabase.co;...
ConnectionStrings__Redis                        | YOUR_REDIS_CONNECTION_STRING
JwtSettings__Secret                             | YOUR_SECRET_KEY
JwtSettings__Issuer                             | https://engreader-api.azurewebsites.net
JwtSettings__Audience                           | https://engreader.com
OpenAI__ApiKey                                  | YOUR_OPENAI_KEY
OpenAI__Model                                   | gpt-4o-mini
WEBSITE_RUN_FROM_PACKAGE                        | 1
```

**⚠️ Restart required after config changes**

#### 3.1.3 GitHub Actions Workflow

**Dosya:** `.github/workflows/azure-deploy.yml`

```yaml
name: Deploy to Azure

on:
  push:
    branches:
      - main
    paths:
      - 'backend/**'
  workflow_dispatch:

env:
  AZURE_WEBAPP_NAME: engreader-api
  DOTNET_VERSION: '8.0.x'
  WORKING_DIRECTORY: './backend'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}

    - name: Restore dependencies
      run: dotnet restore
      working-directory: ${{ env.WORKING_DIRECTORY }}

    - name: Build
      run: dotnet build --configuration Release --no-restore
      working-directory: ${{ env.WORKING_DIRECTORY }}

    - name: Run tests
      run: dotnet test --configuration Release --no-build --verbosity normal
      working-directory: ${{ env.WORKING_DIRECTORY }}

    - name: Publish
      run: dotnet publish Engreader.Api/Engreader.Api.csproj -c Release -o ./publish
      working-directory: ${{ env.WORKING_DIRECTORY }}

    - name: Deploy to Azure Web App
      uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
        package: ${{ env.WORKING_DIRECTORY }}/publish
```

**Secrets Setup (GitHub):**
1. Azure Portal → App Service → Deployment Center
2. Download publish profile
3. GitHub → Settings → Secrets → New repository secret
4. Name: `AZURE_WEBAPP_PUBLISH_PROFILE`
5. Value: (paste publish profile XML)

#### 3.1.4 Custom Domain & SSL

**Azure Portal → Custom domains:**

1. **Domain Ekle:**
   - Custom domain: `api.engreader.com`
   - Validation method: TXT record
   - DNS'e TXT record ekle (domain provider'da)
   - Verify

2. **SSL Certificate:**
   - Azure Managed Certificate (Free)
   - Binding type: SNI SSL
   - Certificate auto-renews

**DNS Records (Domain Provider):**
```
Type    | Host | Value                                      | TTL
--------|------|--------------------------------------------|----- 
CNAME   | api  | engreader-api.azurewebsites.net           | 3600
TXT     | api  | (verification string from Azure)          | 3600
```

**Wait 24-48 hours for DNS propagation**

#### 3.1.5 Test Deployment

```powershell
# Health check
curl https://api.engreader.com/health

# Expected:
# {"status":"Healthy","checks":[{"name":"postgresql","status":"Healthy",...}]}

# Swagger
# https://api.engreader.com/swagger

# Test endpoint
curl https://api.engreader.com/api/v1/auth/login `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"email":"test@test.com","password":"Test123!"}'
```

---

### 3.2 Redis Setup

#### Azure Cache for Redis

**Azure Portal:**
1. "Create a resource" → "Azure Cache for Redis"
2. Basics:
   - Name: `engreader-cache`
   - Location: West Europe
   - Pricing tier: Basic C0 (250 MB) - $16/month
   
3. Advanced:
   - Redis version: 6
   - TLS: Enabled

4. Review + create

**Connection String:**
```
engreader-cache.redis.cache.windows.net:6380,password=YOUR_PRIMARY_KEY,ssl=True,abortConnect=False
```

**Add to App Service Configuration:**
```
ConnectionStrings__Redis = (paste connection string)
```

---

### 3.3 Monitoring & Logging

#### Application Insights

**Azure Portal → engreader-api → Application Insights:**

**Key Metrics:**
- Request rate
- Response time
- Failed requests
- Exceptions
- CPU usage
- Memory usage

**Custom Queries (Log Analytics):**

```kusto
// Failed requests in last 24 hours
requests
| where timestamp > ago(24h)
| where success == false
| summarize count() by bin(timestamp, 1h)
| render timechart

// Slow API calls (>2 seconds)
requests
| where timestamp > ago(24h)
| where duration > 2000
| project timestamp, name, duration, resultCode
| order by duration desc

// OpenAI API usage
dependencies
| where timestamp > ago(24h)
| where name contains "openai"
| summarize count(), avg(duration) by bin(timestamp, 1h)
| render timechart
```

**Alerts:**

1. **High Error Rate**
   - Condition: Failed requests > 10 in 5 minutes
   - Action: Email admin

2. **High Response Time**
   - Condition: Avg response time > 2 seconds
   - Action: Email admin

3. **OpenAI API Errors**
   - Condition: OpenAI dependency failures > 5 in 10 minutes
   - Action: Email + SMS

---

### 3.4 Load Testing

**Install Apache Bench:**
```powershell
# Windows: Download from Apache HTTP Server
# Or use Azure Load Testing
```

**Test:**
```powershell
# 1000 requests, 10 concurrent
ab -n 1000 -c 10 -H "Authorization: Bearer YOUR_TOKEN" `
   https://api.engreader.com/api/v1/stories

# Monitor:
# - Requests per second
# - Mean response time
# - Failed requests (should be 0%)
```

**Target Metrics:**
- ✅ RPS: >50 req/sec
- ✅ Response time: <500ms (p95)
- ✅ Error rate: <0.1%
- ✅ CPU: <70%
- ✅ Memory: <80%

---

## 📱 PHASE 4: Flutter App Build

### 4.1 Production Configuration

#### Update API URL

**Düzenle:** `flutter/engreader_app/lib/core/config/app_config.dart`

```dart
class AppConfig {
  // API Configuration
  static const String baseUrl = kReleaseMode
      ? 'https://api.engreader.com'  // Production
      : 'http://localhost:5000';      // Development
  
  // ...
}
```

**Import ekle:**
```dart
import 'package:flutter/foundation.dart' show kReleaseMode;
```

#### Remove Debug Banners

**Düzenle:** `main.dart`

```dart
MaterialApp.router(
  debugShowCheckedModeBanner: false,  // ← Ekle
  // ...
)
```

---

### 4.2 App Signing (Android)

#### 4.2.1 Keystore Oluştur

```powershell
cd C:\Users\tkurt\Desktop\engreader\flutter\engreader_app\android\app

# Keystore oluştur
keytool -genkey -v -keystore engreader-keystore.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias engreader

# Sorular:
# Enter keystore password: [güçlü şifre]
# Re-enter new password: [tekrar]
# What is your first and last name: Engreader Team
# What is the name of your organizational unit: Development
# What is the name of your organization: Engreader
# What is the name of your City or Locality: Istanbul
# What is the name of your State or Province: Istanbul
# What is the two-letter country code: TR
# Is CN=Engreader Team, OU=Development... correct? yes
# Enter key password: [aynı şifre veya farklı]
```

**⚠️ ÖNEMLİ:**
- `engreader-keystore.jks` dosyasını GÜVENLİ bir yerde sakla
- Şifreleri kaydet
- Asla Git'e commit etme

#### 4.2.2 Key Properties

**Oluştur:** `android/key.properties`

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=engreader
storeFile=engreader-keystore.jks
```

**Add to `.gitignore`:**
```
android/key.properties
android/app/engreader-keystore.jks
```

#### 4.2.3 Gradle Configuration

**Düzenle:** `android/app/build.gradle`

```gradle
// Key properties yükle (before android block)
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

### 4.3 Build APK/AAB

#### 4.3.1 Clean Build

```powershell
cd C:\Users\tkurt\Desktop\engreader\flutter\engreader_app

# Clean
flutter clean
flutter pub get

# Code generation
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Fix any issues before building
```

#### 4.3.2 Build Android App Bundle (AAB)

```powershell
# Build AAB (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

**Size Check:**
```powershell
# AAB size should be < 50 MB
Get-Item build/app/outputs/bundle/release/app-release.aab | Select-Object Length
```

#### 4.3.3 Build APK (for testing)

```powershell
# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Install on device:**
```powershell
# Connect Android device via USB
adb devices

# Install
adb install build/app/outputs/flutter-apk/app-release.apk

# Test
```

---

### 4.4 Build iOS App (macOS gerekli)

```bash
cd flutter/engreader_app

# Clean
flutter clean
flutter pub get

# Code generation
dart run build_runner build --delete-conflicting-outputs

# Build iOS
flutter build ios --release

# Xcode'da aç
open ios/Runner.xcworkspace

# Xcode'da:
# 1. Team seç (Apple Developer Account)
# 2. Bundle ID: com.engreader.app
# 3. Version: 1.0.0
# 4. Build number: 1
# 5. Product → Archive
# 6. Distribute App → App Store Connect
```

---

### 4.5 App Icons & Splash Screen

#### App Icon

**Install:**
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#2196F3"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

**Generate:**
```powershell
flutter pub run flutter_launcher_icons
```

#### Splash Screen

**Install:**
```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.1

flutter_native_splash:
  color: "#2196F3"
  image: assets/splash/splash_icon.png
  android: true
  ios: true
```

**Generate:**
```powershell
flutter pub run flutter_native_splash:create
```

---

## 📲 PHASE 5: App Store Submission

### 5.1 Google Play Store

#### 5.1.1 Play Console Setup

**Adımlar:**
1. https://play.google.com/console adresine git
2. "Create app" tıkla
3. App details:
   - App name: **Engreader**
   - Default language: English (US)
   - App or game: App
   - Free or paid: Free

4. Declarations:
   - Privacy Policy: https://engreader.com/privacy
   - App access: All functionality available without restrictions
   - Ads: No ads
   - Content rating: Complete questionnaire (Everyone)
   - Target audience: 13+
   - Data safety: Complete form

#### 5.1.2 Store Listing

**Main store listing:**

**App name:** Engreader

**Short description (80 chars):**
```
Learn English through AI-generated stories personalized to your level
```

**Full description (4000 chars):**
```
🎓 Master English with Personalized AI Stories

Engreader is your intelligent English learning companion that creates custom stories tailored to your CEFR level (A1-C2), helping you improve reading comprehension, vocabulary, and fluency naturally.

✨ KEY FEATURES

📖 AI-Generated Stories
• Choose your CEFR level (A1-C2)
• Pick topics you're interested in
• Add target vocabulary words
• Get unique, engaging stories in seconds

🔤 Interactive Reading
• Tap any word for instant translation
• Long-press for sentence translation
• Highlighted target vocabulary
• Track your reading time

🎯 Comprehension Quizzes
• 5 multiple-choice questions per story
• Detailed explanations for each answer
• Track your progress over time
• Retry to improve your score

📊 Progress Tracking
• Monitor stories read and quizzes taken
• See your learning streak 🔥
• Track average quiz scores
• Watch your English improve

🌍 Multi-Language Support
• Translate to your native language
• Turkish, Spanish, French, German, and more
• Smart caching for instant translations

🎨 Beautiful, Modern Interface
• Material Design 3
• Clean, distraction-free reading
• Dark mode support (coming soon)
• Smooth animations

🔐 Secure & Private
• Your data is protected
• No ads, no distractions
• Email authentication

Perfect for:
✓ English learners (all levels)
✓ Students preparing for exams
✓ Professionals improving business English
✓ Anyone wanting to read more in English

Download Engreader today and start your personalized English learning journey! 🚀

---

Need help? Contact us: support@engreader.com
Website: https://engreader.com
```

**Screenshots:**
- 📱 Phone: 8 screenshots (required)
  1. Welcome/Login screen
  2. Story list with streak
  3. Story generation form
  4. Story reading with highlighted words
  5. Translation popup
  6. Quiz question
  7. Quiz results
  8. Progress dashboard

- 📱 Tablet (optional): 7 screenshots

**Feature Graphic:**
- Size: 1024 x 500 px
- Design: App logo + "Learn English with AI Stories"

**App icon:**
- Size: 512 x 512 px
- Transparent background not allowed

#### 5.1.3 App Content

**Privacy Policy:**
```
https://engreader.com/privacy
```

**Data Safety:**
- User accounts: Yes (email, name)
- Stored in cloud: Yes
- Encrypted in transit: Yes
- Can request deletion: Yes

**Content Rating:**
- Complete questionnaire
- Expected: Everyone / PEGI 3

#### 5.1.4 Upload AAB

**Testing → Internal testing:**
1. Create new release
2. Upload `app-release.aab`
3. Release name: 1.0.0 (1)
4. Release notes:
   ```
   🎉 Initial release of Engreader!
   
   Features:
   • AI-generated personalized stories
   • Interactive word/sentence translation
   • Comprehension quizzes
   • Progress tracking
   • Multi-language support
   ```
5. Save → Review release → Start rollout to Internal testing

**Testers:**
- Add email addresses
- Send join link
- Test for 1-2 weeks

**Production Release:**
1. Countries: All countries
2. Start rollout to Production
3. Review time: 1-7 days

---

### 5.2 Apple App Store

#### 5.2.1 App Store Connect

**Adımlar:**
1. https://appstoreconnect.apple.com
2. My Apps → ➕
3. New App:
   - Platform: iOS
   - Name: Engreader
   - Primary Language: English (US)
   - Bundle ID: com.engreader.app
   - SKU: ENGREADER001

#### 5.2.2 App Information

**Category:**
- Primary: Education
- Secondary: Productivity

**Content Rights:**
- ✅ Contains third-party content (OpenAI)

**Age Rating:**
- 4+ (No objectionable content)

**Privacy Policy:**
```
https://engreader.com/privacy
```

#### 5.2.3 App Store Listing

**Name:** Engreader

**Subtitle (30 chars):**
```
AI Stories for English Learning
```

**Description (4000 chars):**
```
(Same as Google Play Store)
```

**Keywords (100 chars):**
```
english,learn,reading,stories,ai,vocabulary,quiz,cefr,comprehension,education,language,fluency
```

**Screenshots:**
- 📱 6.5" Display: 3-10 screenshots (required)
- 📱 5.5" Display: 3-10 screenshots (required)
- 📱 iPad Pro: 3-10 screenshots (optional)

**Preview Video (optional):**
- 15-30 seconds
- App demo

#### 5.2.4 Build Upload

**Xcode:**
1. Archive oluştur (Product → Archive)
2. Distribute App
3. Method: App Store Connect
4. Upload
5. Wait for processing (~10 minutes)

**App Store Connect:**
1. Build seç
2. Version: 1.0.0
3. Build: 1
4. What's New in This Version:
   ```
   🎉 Welcome to Engreader!
   
   • AI-generated personalized stories
   • Interactive translations
   • Comprehension quizzes
   • Progress tracking
   • Multi-language support
   ```

#### 5.2.5 Submit for Review

**App Review Information:**
- First Name: [Your First Name]
- Last Name: [Your Last Name]
- Phone: [Your Phone]
- Email: support@engreader.com
- Demo account (if needed):
  - Username: reviewer@engreader.com
  - Password: ReviewPass123!

**Notes:**
```
Thank you for reviewing Engreader!

This app uses OpenAI's GPT-4o-mini API to generate personalized English stories based on user's CEFR level and interests.

Test account provided if needed. All features are accessible without restrictions.

Please let us know if you have any questions!
```

**Submit**

**Review time:** 1-3 days (typically 24 hours)

---

## 🔍 Post-Deployment Checklist

### Backend
- [ ] API running on production URL
- [ ] Health check endpoint responding
- [ ] All 17 endpoints working
- [ ] Database migrations applied
- [ ] Redis cache working
- [ ] SSL certificate active
- [ ] CORS configured correctly
- [ ] Logging to Application Insights
- [ ] Alerts configured
- [ ] Backup strategy in place

### Flutter App
- [ ] Production API URL configured
- [ ] Code generation completed
- [ ] No console errors
- [ ] App signed properly
- [ ] AAB/IPA built successfully
- [ ] Tested on real devices
- [ ] Splash screen working
- [ ] App icon correct
- [ ] Store screenshots ready
- [ ] Privacy policy published

### Stores
- [ ] Google Play Console set up
- [ ] Internal testing completed
- [ ] Production release submitted
- [ ] App Store Connect set up
- [ ] Build uploaded
- [ ] App review submitted

### Marketing
- [ ] Website live (https://engreader.com)
- [ ] Privacy policy page
- [ ] Terms of service page
- [ ] Support email set up (support@engreader.com)
- [ ] Social media accounts created
- [ ] Landing page optimized for SEO

---

## 🎉 Launch Day

### Before Launch
- [ ] Final testing on production environment
- [ ] Monitor dashboards ready
- [ ] Support team briefed
- [ ] Press release prepared
- [ ] Social media posts scheduled

### Launch
- [ ] Release to production (both stores)
- [ ] Announce on social media
- [ ] Send email to beta testers
- [ ] Monitor for issues
- [ ] Respond to user feedback

### Post-Launch (First Week)
- [ ] Monitor crash reports
- [ ] Check user reviews
- [ ] Respond to support emails
- [ ] Track key metrics:
  - Downloads
  - Active users
  - Retention rate
  - Average session duration
  - Story generations per user
  - Quiz completion rate

---

## 📊 Success Metrics

### Week 1 Targets
- ✅ 100+ downloads
- ✅ <1% crash rate
- ✅ ≥4.0 star rating
- ✅ 50% Day 1 retention

### Month 1 Targets
- ✅ 1,000+ downloads
- ✅ 500+ active users
- ✅ ≥4.5 star rating
- ✅ 30% Day 7 retention
- ✅ Avg 3+ stories per user

---

## 🔄 Future Updates

### Version 1.1 (2 weeks after launch)
- Bug fixes
- Performance improvements
- User-requested features

### Version 1.2 (1 month)
- Dark mode
- Offline reading
- Audio pronunciation
- More languages

### Version 2.0 (3 months)
- Social features
- Leaderboards
- Achievement badges
- Premium tier

---

**Hazırlayan:** GitHub Copilot  
**Tarih:** 13 Ekim 2025  
**Durum:** ✅ Deployment Rehberi Hazır  
**Next:** Backend deploy → Flutter build → Store submission
