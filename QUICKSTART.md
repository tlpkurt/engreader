# 🚀 Engreader - Hızlı Başlangıç Rehberi

## Adım 1: Kurulum (İlk Kez)

### Otomatik Kurulum (Önerilen)

1. **PowerShell'i Administrator olarak aç:**
   - Windows tuşuna bas
   - "PowerShell" yaz
   - Sağ tık → "Run as Administrator"

2. **Kurulum script'ini çalıştır:**
   ```powershell
   cd C:\Users\tkurt\Desktop\engreader
   .\setup.ps1
   ```

   Bu script otomatik olarak kurar:
   - ✅ PostgreSQL 16 + pgvector
   - ✅ Redis
   - ✅ .NET 8 SDK (zaten kurulu)
   - ✅ Flutter
   - ✅ Git
   - ✅ Node.js
   - ✅ EF Core Tools
   - ✅ Database migration'ları

3. **OpenAI API Key ekle:**
   ```powershell
   # backend\.env dosyasını aç ve düzenle
   notepad backend\.env
   
   # Bu satırı bul ve kendi API key'ini ekle:
   OPENAI_API_KEY=your-openai-api-key-here
   ```

---

## Adım 2: Backend'i Başlat

```powershell
cd C:\Users\tkurt\Desktop\engreader\backend
.\start-backend.ps1
```

✅ Backend hazır: http://localhost:5000
📚 Swagger: http://localhost:5000/swagger

---

## Adım 3: Flutter App'i Başlat

**Yeni bir PowerShell penceresi aç** (backend çalışırken):

```powershell
cd C:\Users\tkurt\Desktop\engreader\flutter\engreader_app
.\start-flutter.ps1
```

İlk çalıştırmada:
- Packages indirilir (~2 dakika)
- Code generation yapılır (~1 dakika)
- App başlar

---

## Manuel Kurulum (Setup script çalışmazsa)

### 1. PostgreSQL Kurulumu

```powershell
# Chocolatey ile kur
choco install postgresql16 --params '/Password:postgres' -y

# Servisi başlat
Get-Service -Name "postgresql*" | Start-Service

# Database oluştur
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE engreader;"

# pgvector extension ekle
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d engreader -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

### 2. Redis Kurulumu

```powershell
# Chocolatey ile kur
choco install redis-64 -y

# Servisi başlat
Start-Service Redis
```

### 3. Flutter Kurulumu

```powershell
# Chocolatey ile kur
choco install flutter -y

# Terminal'i kapat ve tekrar aç (PATH güncellensin)

# Flutter doctor çalıştır
flutter doctor
```

### 4. Backend Setup

```powershell
cd C:\Users\tkurt\Desktop\engreader\backend

# EF Core tools kur
dotnet tool install --tool-path ./tools dotnet-ef

# Packages restore
dotnet restore

# Migration çalıştır
.\tools\dotnet-ef database update --project Engreader.Api --context EngreaderDbContext

# Backend'i başlat
dotnet run --project Engreader.Api/Engreader.Api.csproj
```

### 5. Flutter Setup

```powershell
cd C:\Users\tkurt\Desktop\engreader\flutter\engreader_app

# Packages indir
flutter pub get

# Code generation
dart run build_runner build --delete-conflicting-outputs

# App'i başlat
flutter run
```

---

## 🔧 Sorun Giderme

### PostgreSQL çalışmıyor

```powershell
# Servisi kontrol et
Get-Service -Name "postgresql*"

# Başlat
Get-Service -Name "postgresql*" | Start-Service

# Port kontrolü
Test-NetConnection -ComputerName localhost -Port 5432
```

### Redis çalışmıyor

```powershell
# Servisi kontrol et
Get-Service -Name "Redis"

# Başlat
Start-Service Redis

# Port kontrolü
Test-NetConnection -ComputerName localhost -Port 6379
```

### Flutter bulunamıyor

```powershell
# PATH'e ekle (terminal'i yeniden başlat)
$env:Path += ";C:\tools\flutter\bin"

# Kalıcı olarak ekle (System Properties > Environment Variables)
# Path değişkenine ekle: C:\tools\flutter\bin
```

### Code generation hatası

```powershell
cd C:\Users\tkurt\Desktop\engreader\flutter\engreader_app

# Cache temizle
flutter clean

# Packages tekrar indir
flutter pub get

# Build runner temizle ve tekrar çalıştır
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Backend migration hatası

```powershell
cd C:\Users\tkurt\Desktop\engreader\backend

# Database'i sil ve yeniden oluştur
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "DROP DATABASE IF EXISTS engreader;"
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "CREATE DATABASE engreader;"
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d engreader -c "CREATE EXTENSION IF NOT EXISTS vector;"

# Migration tekrar çalıştır
.\tools\dotnet-ef database update --project Engreader.Api --context EngreaderDbContext
```

---

## 📝 Önemli Notlar

### OpenAI API Key
- **Zorunlu**: Story ve quiz generation için gerekli
- **Nasıl alınır**: https://platform.openai.com/api-keys
- **Maliyet**: GPT-4o-mini çok ucuz (~$0.15 / 1M token)
- **Nereye eklenir**: `backend\.env` dosyasına

### Database Şifresi
- **Default**: postgres / postgres
- **Değiştirmek için**: `backend\.env` dosyasını düzenle

### Port'lar
- **Backend API**: 5000
- **PostgreSQL**: 5432
- **Redis**: 6379
- **Flutter Debug**: Otomatik (genelde 8080+)

---

## ✅ Hızlı Kontrol

Her şey çalışıyor mu kontrol et:

```powershell
# PostgreSQL
Test-NetConnection -ComputerName localhost -Port 5432

# Redis
Test-NetConnection -ComputerName localhost -Port 6379

# Backend API
curl http://localhost:5000/health

# Flutter (tarayıcıda)
http://localhost:xxxxx  # (flutter run çıktısında gösterilen port)
```

---

## 🎉 Başarılı Kurulum

Eğer her şey çalışıyorsa:

1. ✅ Backend API: http://localhost:5000
2. ✅ Swagger: http://localhost:5000/swagger
3. ✅ Flutter App çalışıyor
4. ✅ Login ekranı görünüyor

**Artık hazırsın! 🚀**

Test hesabı oluştur:
- Email: test@test.com
- Password: Test123!

---

## 📚 Daha Fazla Bilgi

- **Code Generation**: `flutter/CODE_GENERATION_GUIDE.md`
- **Test Senaryoları**: `TEST_SCENARIOS.md`
- **Deployment**: `DEPLOYMENT_GUIDE.md`
- **API Dokümantasyonu**: http://localhost:5000/swagger (backend çalışırken)

---

**Hazırlayan**: GitHub Copilot  
**Tarih**: 13 Ekim 2025  
**Versiyon**: 1.0.0
