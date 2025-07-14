# Copilot Instructions for Climaguate

## Project Overview
Climaguate is a cloud-native weather data platform for Guatemala, built with Azure, Python, .NET Blazor, and CI/CD via GitHub Actions. It collects, processes, and presents weather data using serverless functions, a SQL database, and a modern web frontend.

## Architecture & Major Components
- **backend/**: Python Azure Functions for data collection (weather, maps, news). Key file: `app.py`.
- **frontend/Client/**: .NET Blazor static web app for data presentation. Key files: `App.razor`, `Pages/`, `wwwroot/`.
- **database/**: SQL scripts and schema for weather data storage. Key files: `WeatherData.sql`, `get_weather.sql`.
- **infrastructure/ADF/**: Azure Data Factory JSON configs for orchestration.
- **.github/workflows/**: GitHub Actions for CI/CD. Main workflow: `main_weathercrawler.yml` (deploys backend).

## Data Flow
- Azure Functions (Python) crawl external APIs and social media, using secrets from Azure Key Vault.
- Data is stored in Azure SQL via SQL scripts.
- Data API Builder exposes SQL data as JSON for the frontend.
- Blazor frontend fetches and displays weather data to users.

## Developer Workflows
- **Build & Deploy Backend**: Triggered by changes in `backend/**`. Workflow: `.github/workflows/main_weathercrawler.yml`.
  - Uses Python 3.12, installs from `backend/requirements.txt`, deploys zipped `backend/`.
- **Frontend Build**: .NET Blazor, standard `dotnet build` and publish.
- **Database Updates**: SQL scripts in `database/` are deployed manually or via pipeline.
- **Local Dev**: Use Codespaces or VS Code with recommended extensions (see README).

## Key Patterns & Conventions
- **Secrets & Config**: All sensitive info (API keys, connection strings) is stored in Azure Key Vault and injected at runtime.
- **Function App Structure**: Only valid files in `backend/` (`app.py`, `host.json`, `requirements.txt`). No test or venv folders in deployment.
- **CI/CD**: Each major folder (backend, frontend, database, infrastructure) has a matching workflow for deployment.
- **Python Functions**: Defined in `app.py` using Azure Functions SDK. Entry points must match Azure's requirements.
- **Frontend Routing**: Blazor pages in `frontend/Client/Pages/`.
- **Database Access**: Use parameterized queries in SQL scripts for security.

## Integration Points
- **Azure Key Vault**: Used by backend for secrets.
- **Azure SQL**: Central data store, accessed by backend and Data API Builder.
- **Azure Blob Storage**: Used for storing map images and other assets.
- **Data API Builder**: Converts SQL data to JSON for frontend.

## Example: Backend Deployment Workflow
```yaml
# .github/workflows/main_weathercrawler.yml
on:
  push:
    branches: [main]
    paths: ['backend/**']
jobs:
  build:
    steps:
      - name: Install dependencies
        run: pip install -r backend/requirements.txt
      - name: Zip backend
        run: cd backend && zip -r ../release.zip .
  deploy:
    steps:
      - name: Deploy to Azure Functions
        uses: Azure/functions-action@v1
        with:
          app-name: 'WeatherCrawler'
          package: backend
```

## References
- See `README.md` for architecture and workflow details.
- See `.github/workflows/` for CI/CD logic.
- See `backend/app.py` for Azure Function entry points.
- See `database/` for SQL schema and scripts.
- See `frontend/Client/` for Blazor app structure.

---
If any section is unclear or missing, please provide feedback to improve these instructions.
