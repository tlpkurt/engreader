# Engreader Backend (.NET 9)

## Architecture
Clean Architecture with the following layers:

- **Engreader.Api**: Web API Controllers, Middleware, Configuration
- **Engreader.Application**: Services, DTOs, Business Logic
- **Engreader.Domain**: Core Entities, Value Objects, Domain Logic
- **Engreader.Infrastructure**: Database Context, Repositories, External Services
- **Engreader.Contracts**: Request/Response DTOs, API Contracts
- **Engreader.Background**: Background Workers, Scheduled Jobs

## Tech Stack
- .NET 9
- PostgreSQL 16 + pgvector
- Redis 7
- Entity Framework Core 9
- MediatR + FluentValidation
- JWT Authentication
- Swagger/OpenAPI

## Getting Started

### Prerequisites
- .NET 9 SDK
- PostgreSQL 16 with pgvector extension
- Redis 7

### Setup
1. Update connection strings in `appsettings.json`
2. Run migrations:
   ```bash
   dotnet ef database update --project src/Engreader.Infrastructure --startup-project src/Engreader.Api
   ```
3. Run the API:
   ```bash
   dotnet run --project src/Engreader.Api
   ```

### API Documentation
Swagger UI: https://localhost:5001/swagger

## Project Structure
```
backend/
├── src/
│   ├── Engreader.Api/          # API Layer
│   ├── Engreader.Application/  # Application Layer
│   ├── Engreader.Domain/       # Domain Layer
│   ├── Engreader.Infrastructure/ # Infrastructure Layer
│   ├── Engreader.Contracts/    # Contracts/DTOs
│   └── Engreader.Background/   # Background Jobs
└── Engreader.sln
```
