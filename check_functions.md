# Check Functions in Azure

## Method 1: Azure CLI
```bash
# List all functions in your app
az functionapp function list --name WeatherCrawler --resource-group [your-resource-group] --output table

# Get function app status
az functionapp show --name WeatherCrawler --resource-group [your-resource-group] --query "{name:name, state:state, hostNames:hostNames}" --output table
```

## Method 2: Check in Portal
1. Go to https://portal.azure.com
2. Search for "WeatherCrawler"
3. Click on Functions → should show:
   - run_city_batch (Timer)
   - get_quarterday_forecast (Timer)

## Method 3: Check Function Logs
1. In Azure Portal → WeatherCrawler
2. Go to Monitor → Log Stream
3. Look for any Python errors or import failures

## Common issues if functions don't appear:
1. Python syntax errors in function_app.py
2. Missing imports
3. Incorrect decorators
4. Runtime version mismatch
