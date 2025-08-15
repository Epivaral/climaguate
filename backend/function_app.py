import logging
import os
import json
import azure.functions as func
from urllib.request import urlopen, Request
from urllib.parse import urlencode
from urllib.error import URLError, HTTPError

app = func.FunctionApp()


@app.function_name("health_check")
@app.route(route="health")
def health_check(req: func.HttpRequest) -> func.HttpResponse:
    """Health check endpoint."""
    logging.info('Health check endpoint called')
    return func.HttpResponse(
        "WeatherCrawler is running! Using built-in libraries only.",
        status_code=200
    )


# ==================== WEATHER DATA FUNCTION ====================
@app.function_name("collect_weather_data")
@app.schedule(schedule="0 */15 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def collect_weather_data(timer: func.TimerRequest) -> None:
    """Collect weather data using urllib (built-in) and environment variables."""
    if timer.past_due:
        logging.info('The timer is past due!')

    try:
        logging.info('Starting weather data collection with built-in libraries...')
        
        # Use environment variables instead of Key Vault
        apikey = os.environ.get('WEATHER_API_KEY', 'test_key')
        logging.info(f'API key loaded: {apikey[:10]}...')
        
        # Hard-coded cities for now (we'll solve database later)
        cities = [
            {'code': 'GT01', 'name': 'Guatemala City', 'lat': 14.6349, 'lon': -90.5069},
            {'code': 'GT02', 'name': 'Quetzaltenango', 'lat': 14.8333, 'lon': -91.5167},
            {'code': 'GT03', 'name': 'Escuintla', 'lat': 14.3056, 'lon': -90.7850}
        ]
        
        logging.info(f'Processing {len(cities)} cities for weather data')

        success_count = 0
        failure_count = 0
        
        # Process each city using urllib
        for city in cities:
            city_code = city['code']
            city_name = city['name']
            latitude = city['lat']
            longitude = city['lon']

            logging.info(f"Processing weather for {city_code} - {city_name}")

            try:
                # Build OpenWeatherMap API URL
                params = {
                    'lat': latitude,
                    'lon': longitude,
                    'appid': apikey,
                    'lang': 'es',
                    'units': 'metric'
                }
                
                api_url = f"https://api.openweathermap.org/data/2.5/weather?{urlencode(params)}"
                
                # Make HTTP request using urllib (built-in)
                request = Request(api_url)
                request.add_header('User-Agent', 'ClimaguateWeatherApp/1.0')
                
                with urlopen(request, timeout=15) as response:
                    if response.status == 200:
                        data = json.loads(response.read().decode('utf-8'))
                        
                        # Extract weather data
                        weather_info = {
                            'city_code': city_code,
                            'city_name': city_name,
                            'temperature': data['main']['temp'],
                            'feels_like': data['main']['feels_like'],
                            'humidity': data['main']['humidity'],
                            'pressure': data['main']['pressure'],
                            'description': data['weather'][0]['description'],
                            'wind_speed': data['wind']['speed'],
                            'timestamp': data['dt']
                        }
                        
                        logging.info(f"✅ {city_code}: {weather_info['temperature']}°C, {weather_info['description']}")
                        success_count += 1
                        
                        # For now, just log the data (we'll add database storage later)
                        logging.info(f"Weather data for {city_code}: {json.dumps(weather_info, indent=2)}")
                        
                    else:
                        logging.error(f"❌ HTTP {response.status} for {city_code}")
                        failure_count += 1

            except HTTPError as e:
                logging.error(f"❌ HTTP error for {city_code}: {e}")
                failure_count += 1
            except URLError as e:
                logging.error(f"❌ URL error for {city_code}: {e}")
                failure_count += 1
            except json.JSONDecodeError as e:
                logging.error(f"❌ JSON decode error for {city_code}: {e}")
                failure_count += 1
            except Exception as e:
                logging.error(f"❌ Unexpected error for {city_code}: {e}")
                failure_count += 1

        logging.info(f'✅ Weather collection completed: {success_count}/{len(cities)} successful, {failure_count} failed')

    except Exception as e:
        logging.error(f"❌ Critical error in collect_weather_data: {str(e)}")


# ==================== NASA IMAGE FUNCTION ====================
@app.function_name("collect_nasa_images")  
@app.schedule(schedule="5 */15 * * * *", arg_name="nasaTimer", run_on_startup=False, use_monitor=False)
def collect_nasa_images(nasaTimer: func.TimerRequest) -> None:
    """Collect NASA satellite images using built-in libraries."""
    if nasaTimer.past_due:
        logging.info('The timer is past due!')

    try:
        logging.info('Starting NASA image collection with built-in libraries...')
        
        cities = [
            {'code': 'GT01', 'name': 'Guatemala City', 'lat': 14.6349, 'lon': -90.5069},
            {'code': 'GT02', 'name': 'Quetzaltenango', 'lat': 14.8333, 'lon': -91.5167}
        ]
        
        success_count = 0
        failure_count = 0

        for city in cities:
            city_code = city['code']
            city_name = city['name']
            latitude = city['lat']
            longitude = city['lon']

            logging.info(f"Processing NASA image for {city_code} - {city_name}")

            try:
                # NASA GOES image URL
                nasa_url = (
                    f"https://weather.ndc.nasa.gov/cgi-bin/get-abi?"
                    f"satellite=GOESEastfullDiskband13&lat={latitude}&lon={longitude}"
                    f"&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
                )
                
                # For now, just test URL access (we'll add image processing later)
                request = Request(nasa_url)
                with urlopen(request, timeout=30) as response:
                    if response.status == 200:
                        content_length = len(response.read())
                        logging.info(f"✅ {city_code}: NASA image loaded ({content_length} bytes)")
                        success_count += 1
                    else:
                        logging.error(f"❌ HTTP {response.status} for NASA image {city_code}")
                        failure_count += 1

            except Exception as e:
                logging.error(f"❌ NASA image error for {city_code}: {e}")
                failure_count += 1

        logging.info(f'✅ NASA image collection completed: {success_count}/{len(cities)} successful, {failure_count} failed')

    except Exception as e:
        logging.error(f"❌ Critical error in collect_nasa_images: {str(e)}")
