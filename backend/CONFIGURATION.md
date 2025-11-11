# Engreader - Configuration

## API Keys

For security, sensitive keys are not stored in `appsettings.json`. 

### Local Development

Create `appsettings.Development.local.json` in `backend/src/Engreader.Api/`:

```json
{
  "OpenAI": {
    "ApiKey": "your-openai-api-key-here"
  }
}
```

### Production (Docker)

The API key is already configured on the server. If you need to update it:

```bash
ssh root@84.247.20.85
# Edit the file on server
nano /path/to/appsettings.json
# Or use docker cp to update
```

## Environment Variables

Alternatively, set environment variables:
- `OpenAI__ApiKey` - Your OpenAI API key
