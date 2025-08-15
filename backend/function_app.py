import logging
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

app = func.FunctionApp()

# Test: Azure clients but NO requests


@app.function_name("health_check")
@app.route(route="health")
def health_check(req: func.HttpRequest) -> func.HttpResponse:
    """Health check endpoint."""
    logging.info('Health check endpoint called')
    return func.HttpResponse(
        "WeatherCrawler is running! NO HELPER IMPORTS.",
        status_code=200
    )


# ==================== WEATHER DATA FUNCTION ====================
@app.function_name("collect_weather_data")
@app.schedule(schedule="0 */15 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def collect_weather_data(timer: func.TimerRequest) -> None:
    """Test function without Azure clients - identify the exact problem."""
    if timer.past_due:
        logging.info('The timer is past due!')

    try:
        logging.info('Starting weather collection with Azure clients but NO requests...')
        
        # TEST: Azure clients without requests
        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)
        logging.info('Azure clients initialized successfully!')
        
        cities = [
            {'code': 'GT01', 'name': 'Guatemala', 'lat': 14.6349, 'lon': -90.5069},
            {'code': 'GT02', 'name': 'Quetzaltenango', 'lat': 14.8333, 'lon': -91.5167}
        ]
        
        logging.info(f'Processing {len(cities)} cities for weather data')

        success_count = 0
        
        # Process each city - Azure clients work but NO HTTP requests
        for city in cities:
            city_code = city['code']
            city_name = city['name']
            latitude = city['lat']
            longitude = city['lon']

            logging.info(f"Processing weather for {city_code} - {city_name} at {latitude},{longitude}")
            
            # Simulate processing - NO requests calls
            success_count += 1

        logging.info(f'Weather collection completed: {success_count}/{len(cities)} successful - Azure clients worked')

    except Exception as e:
        logging.error(f"Error in collect_weather_data: {str(e)}")
