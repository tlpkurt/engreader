# 📚 Engreader

AI-powered English learning platform with personalized stories, interactive translations, and comprehension quizzes.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![.NET](https://img.shields.io/badge/.NET-8.0-purple.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.24+-blue.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg)

## ✨ Features

- 🤖 **AI-Generated Stories** - Personalized stories based on your CEFR level (A1-C2)
- 🔤 **Interactive Reading** - Tap words for instant translation, long-press for sentence translation
- 🎯 **Comprehension Quizzes** - 5 MCQ questions per story with detailed explanations
- 📊 **Progress Tracking** - Monitor your learning journey with stats and streaks
- 🌍 **Multi-Language Support** - Translate to your native language
- 🎨 **Modern UI** - Beautiful Material Design 3 interface

## 🏗️ Architecture

### Backend (.NET 8)
- **Clean Architecture** with 6 projects
- **PostgreSQL 16** with pgvector for semantic search
- **Redis** for translation caching
- **OpenAI GPT-4o-mini** for story and quiz generation
- **JWT Authentication** with refresh tokens
- **17 REST API Endpoints**

### Frontend (Flutter 3.24+)
- **Riverpod** for state management
- **go_router** for navigation
- **Dio** for HTTP client
- **freezed** for immutable models
- **Material Design 3** UI

## 🚀 Quick Start

### Prerequisites
- Windows 10/11
- Administrator privileges (for initial setup)
- Internet connection

### Automated Setup (Recommended)

1. **Clone the repository:**
   ```powershell
   git clone https://github.com/yourusername/engreader.git
   cd engreader
   ```

2. **Run setup script (as Administrator):**
   ```powershell
   # Right-click PowerShell -> Run as Administrator
   cd C:\path\to\engreader
   .\setup.ps1
   ```

   This will automatically install:
   - ✅ .NET 8 SDK
   - ✅ PostgreSQL 16 + pgvector
   - ✅ Redis
   - ✅ Git
   - ✅ Node.js
   - ✅ Flutter
   - ✅ EF Core Tools

3. **Configure Secrets:**
   
   Create `appsettings.Development.local.json` in `backend/src/Engreader.Api/`:
   ```json
   {
     "ConnectionStrings": {
       "PostgreSQL": "Host=localhost;Port=5432;Database=engreader;Username=postgres;Password=YOUR_PASSWORD"
     },
     "JwtSettings": {
       "Secret": "YOUR_SECRET_KEY_AT_LEAST_32_CHARACTERS"
     },
     "OpenAI": {
       "ApiKey": "sk-your-openai-api-key-here"
     }
   }
   ```
   
   ⚠️ **Important**: Never commit this file to git!

4. **Start Backend:**
   ```powershell
   cd backend
   .\start-backend.ps1
   ```
   
   Backend will be available at: http://localhost:5000
   Swagger docs: http://localhost:5000/swagger

5. **Start Flutter App (in a new terminal):**
   ```powershell
   cd flutter\engreader_app
   .\start-flutter.ps1
   ```

### Manual Setup

<details>
<summary>Click to expand manual setup instructions</summary>

#### 1. Install Dependencies

**Install Chocolatey (Package Manager):**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

**Install required packages:**
```powershell
choco install dotnet-sdk -y
choco install postgresql16 --params '/Password:postgres' -y
choco install redis-64 -y
choco install git -y
choco install nodejs-lts -y
choco install flutter -y
```

#### 2. Setup Database

```powershell
# Create database
psql -U postgres -c "CREATE DATABASE engreader;"

# Install pgvector extension
psql -U postgres -d engreader -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

#### 3. Setup Backend

```powershell
cd backend

# Install EF Core tools
dotnet tool install --tool-path ./tools dotnet-ef

# Restore packages
dotnet restore

# Run migrations
.\tools\dotnet-ef database update --project Engreader.Api --context EngreaderDbContext

# Start API
dotnet run --project Engreader.Api/Engreader.Api.csproj
```

#### 4. Setup Flutter

```powershell
cd flutter\engreader_app

# Get packages
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

</details>

## 📁 Project Structure

```
engreader/
├── backend/                     # .NET 8 Backend
│   ├── Engreader.Domain/        # Entities, Enums, Value Objects
│   ├── Engreader.Application/   # Business Logic, Services, DTOs
│   ├── Engreader.Infrastructure/# Data Access, External Services
│   ├── Engreader.Api/           # REST API, Controllers
│   ├── .env.example             # Environment variables template
│   └── start-backend.ps1        # Backend startup script
│
├── flutter/
│   └── engreader_app/           # Flutter App
│       ├── lib/
│       │   ├── core/            # Config, Theme, Router, API Client
│       │   └── features/        # Feature modules
│       │       ├── auth/        # Authentication
│       │       ├── story/       # Story generation & reading
│       │       ├── quiz/        # Quizzes
│       │       ├── translation/ # Word/sentence translation
│       │       └── progress/    # Progress tracking
│       ├── .env.example         # Flutter environment variables
│       └── start-flutter.ps1    # Flutter startup script
│
├── setup.ps1                    # Automated setup script
├── CODE_GENERATION_GUIDE.md     # Code generation instructions
├── TEST_SCENARIOS.md            # Testing guide
├── DEPLOYMENT_GUIDE.md          # Production deployment guide
└── README.md                    # This file
```

## 🧪 Testing

Run the comprehensive test suite:

```powershell
# Backend tests
cd backend
dotnet test

# Flutter tests
cd flutter\engreader_app
flutter test
```

See [TEST_SCENARIOS.md](TEST_SCENARIOS.md) for detailed test cases.

## 📚 Documentation

- **[CODE_GENERATION_GUIDE.md](flutter/CODE_GENERATION_GUIDE.md)** - Flutter code generation guide
- **[TEST_SCENARIOS.md](TEST_SCENARIOS.md)** - Complete testing scenarios (46 test cases)
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Production deployment instructions
- **[FINAL_PROJECT_COMPLETE.md](FINAL_PROJECT_COMPLETE.md)** - Project completion summary

## 🔑 Environment Variables

### Backend (.env)
```env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=engreader
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres

REDIS_HOST=localhost
REDIS_PORT=6379

JWT_SECRET=your-secret-key-here
OPENAI_API_KEY=sk-your-api-key-here
```

### Flutter (.env)
```env
API_BASE_URL=http://localhost:5000
```

## 🛠️ Tech Stack

### Backend
- .NET 8.0
- PostgreSQL 16 + pgvector
- Redis 7
- Entity Framework Core 9.0
- OpenAI GPT-4o-mini
- Swagger/OpenAPI
- JWT Authentication

### Frontend
- Flutter 3.24+
- Dart 3.5+
- Riverpod 2.5.1
- go_router 14.2.7
- Dio 5.7.0
- freezed 2.5.7
- json_serializable 6.8.0
- Material Design 3

## 📊 Project Statistics

- **Total Files**: 110+
- **Lines of Code**: ~13,000
- **Backend Endpoints**: 17
- **Flutter Screens**: 9
- **Database Tables**: 10
- **Features**: 10 major features

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - Initial work

## 🙏 Acknowledgments

- OpenAI for GPT-4o-mini API
- Flutter team for the amazing framework
- .NET team for Clean Architecture patterns
- PostgreSQL team for pgvector extension

## 📧 Support

For support, email support@engreader.com or open an issue on GitHub.

## 🗺️ Roadmap

### Version 1.1 (Q1 2026)
- [ ] Dark mode
- [ ] Offline reading
- [ ] Audio pronunciation
- [ ] More translation languages

### Version 1.2 (Q2 2026)
- [ ] Social features
- [ ] Leaderboards
- [ ] Achievement badges
- [ ] Story sharing

### Version 2.0 (Q3 2026)
- [ ] Premium tier
- [ ] Custom story templates
- [ ] Voice reading
- [ ] Mobile apps (iOS/Android)

---

Made with ❤️ by the Engreader Team
