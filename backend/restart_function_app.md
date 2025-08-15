# Restart Your Function App

## Option 1: Azure Portal (Easiest)
1. Go to Azure Portal → WeatherCrawler
2. Click **Restart** in the top menu
3. Wait 2-3 minutes
4. Go to Functions → Should now show your functions

## Option 2: Azure CLI
```bash
# Restart the function app
az functionapp restart --name WeatherCrawler --resource-group [your-resource-group]

# Check if functions are now visible
az functionapp function list --name WeatherCrawler --resource-group [your-resource-group] --output table
```
