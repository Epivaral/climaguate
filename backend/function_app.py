import logging
import os
import json
import azure.functions as func
from urllib.request import urlopen, Request
from urllib.parse import urlencode
from urllib.error import URLError, HTTPError

app = func.FunctionApp()

# ==================== HELPER FUNCTIONS ====================

def get_cities_from_api():
    """Fetch cities from Data API Builder endpoint."""
    try:
        api_url = "https://climaguate.com/data-api/rest/GetCities"
        
        request = Request(api_url)
        request.add_header('User-Agent', 'ClimaguateWeatherApp/1.0')
        
        with urlopen(request, timeout=10) as response:
            if response.status == 200:
                data = json.loads(response.read().decode('utf-8'))
                cities_list = data.get('value', [])
                
                # Add coordinates for known cities (you can extend this)
                city_coords = {
                    'GUA': {'Latitude': 14.6349, 'Longitude': -90.5069},
                    'QEZ': {'Latitude': 14.8333, 'Longitude': -91.5167},
                    'ESC': {'Latitude': 14.3056, 'Longitude': -90.7850},
                    'ANT': {'Latitude': 14.5583, 'Longitude': -90.7344},
                    'COB': {'Latitude': 15.4781, 'Longitude': -90.3709},
                    'FLO': {'Latitude': 16.9268, 'Longitude': -89.8936},
                    'HUE': {'Latitude': 15.3197, 'Longitude': -91.4690},
                    'PUE': {'Latitude': 15.7297, 'Longitude': -88.5956},
                    'RET': {'Latitude': 14.5406, 'Longitude': -91.6817}
                }
                
                # Add coordinates to cities
                for city in cities_list:
                    city_code = city.get('CityCode', '')
                    if city_code in city_coords:
                        city.update(city_coords[city_code])
                    else:
                        # Default coordinates for cities without specific location
                        city.update({'Latitude': 14.6349, 'Longitude': -90.5069})
                
                logging.info(f"✅ Loaded {len(cities_list)} cities from API")
                return cities_list
            else:
                logging.error(f"❌ HTTP {response.status} from cities API")
                return None
                
    except Exception as e:
        logging.error(f"❌ Error fetching cities: {e}")
        return None


def store_weather_data(weather_data):
    """Store weather data via Data API Builder (placeholder for now)."""
    try:
        # For now, just log the data structure
        # Later you can implement POST to your Data API Builder endpoint
        logging.info(f"📊 Weather data ready for storage: {json.dumps(weather_data, indent=2)}")
        return True
    except Exception as e:
        logging.error(f"❌ Error storing weather data: {e}")
        return False


def store_nasa_image(city_code, image_data):
    """Store NASA satellite image (placeholder for now)."""
    try:
        # For now, just log image info
        # Later you can upload to Azure Blob Storage
        logging.info(f"🛰️ NASA image for {city_code}: {len(image_data)} bytes ready for storage")
        return True
    except Exception as e:
        logging.error(f"❌ Error storing NASA image: {e}")
        return False


# ==================== AZURE FUNCTIONS ====================

@app.function_name("health_check")
@app.route(route="health")
def health_check(req: func.HttpRequest) -> func.HttpResponse:
    """Health check endpoint."""
    logging.info('Health check endpoint called')
    return func.HttpResponse(
        "WeatherCrawler is running! Using Data API Builder integration.",
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
        
        # Get cities from Data API Builder
        cities_data = get_cities_from_api()
        if not cities_data:
            logging.error('❌ Failed to fetch cities from API - using fallback')
            cities_data = [
                {'CityCode': 'GUA', 'CityName': 'Guatemala City', 'Latitude': 14.6349, 'Longitude': -90.5069},
                {'CityCode': 'QEZ', 'CityName': 'Quetzaltenango', 'Latitude': 14.8333, 'Longitude': -91.5167},
                {'CityCode': 'ESC', 'CityName': 'Escuintla', 'Latitude': 14.3056, 'Longitude': -90.7850}
            ]
        
        
        logging.info(f'Processing {len(cities_data)} cities for weather data')

        success_count = 0
        failure_count = 0
        
        # Process each city using urllib
        for city in cities_data:
            city_code = city.get('CityCode', 'UNK')
            city_name = city.get('CityName', 'Unknown')
            latitude = city.get('Latitude', 14.6349)
            longitude = city.get('Longitude', -90.5069)

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
                        
                        # Extract weather data matching your database schema
                        weather_info = {
                            'CityCode': city_code,
                            'CityName': city_name,
                            'Coord_Lon': longitude,
                            'Coord_Lat': latitude,
                            'Weather_Id': data['weather'][0]['id'],
                            'Weather_Main': data['weather'][0]['main'],
                            'Weather_Description': data['weather'][0]['description'],
                            'Weather_Icon': data['weather'][0]['icon'],
                            'Main_Temp': data['main']['temp'],
                            'Main_Feels_Like': data['main']['feels_like'],
                            'Main_Pressure': data['main']['pressure'],
                            'Main_Humidity': data['main']['humidity'],
                            'Main_Temp_Min': data['main']['temp_min'],
                            'Main_Temp_Max': data['main']['temp_max'],
                            'Visibility': data.get('visibility', 0),
                            'Wind_Speed': data.get('wind', {}).get('speed', 0),
                            'Wind_Deg': data.get('wind', {}).get('deg', 0),
                            'Wind_Gust': data.get('wind', {}).get('gust', 0),
                            'Clouds_All': data.get('clouds', {}).get('all', 0),
                            'Rain_1h': data.get('rain', {}).get('1h', 0),
                            'Rain_3h': data.get('rain', {}).get('3h', 0),
                            'Dt': data['dt'],
                            'Sys_Country': data['sys']['country'],
                            'Sys_Sunrise': data['sys']['sunrise'],
                            'Sys_Sunset': data['sys']['sunset'],
                            'Timezone': data['timezone'],
                            'Id': data['id']
                        }
                        
                        logging.info(f"✅ {city_code}: {weather_info['Main_Temp']}°C, {weather_info['Weather_Description']}")
                        
                        # Store weather data
                        if store_weather_data(weather_info):
                            success_count += 1
                        else:
                            failure_count += 1
                        
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

        logging.info(f'✅ Weather collection completed: {success_count}/{len(cities_data)} successful, {failure_count} failed')

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
        
        # Get cities from Data API Builder  
        cities_data = get_cities_from_api()
        if not cities_data:
            logging.error('❌ Failed to fetch cities for NASA images - using fallback')
            cities_data = [
                {'CityCode': 'GUA', 'CityName': 'Guatemala City', 'Latitude': 14.6349, 'Longitude': -90.5069},
                {'CityCode': 'QEZ', 'CityName': 'Quetzaltenango', 'Latitude': 14.8333, 'Longitude': -91.5167}
            ]
        
        success_count = 0
        failure_count = 0

        # Process ALL cities for NASA images
        for city in cities_data:
            city_code = city.get('CityCode', 'UNK')
            city_name = city.get('CityName', 'Unknown')
            latitude = city.get('Latitude', 14.6349)
            longitude = city.get('Longitude', -90.5069)

            logging.info(f"Processing NASA image for {city_code} - {city_name}")

            try:
                # NASA GOES image URL
                nasa_url = (
                    f"https://weather.ndc.nasa.gov/cgi-bin/get-abi?"
                    f"satellite=GOESEastfullDiskband13&lat={latitude}&lon={longitude}"
                    f"&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
                )
                
                # Download NASA image
                request = Request(nasa_url)
                with urlopen(request, timeout=30) as response:
                    if response.status == 200:
                        image_data = response.read()
                        logging.info(f"✅ {city_code}: NASA image downloaded ({len(image_data)} bytes)")
                        
                        # Store image data
                        if store_nasa_image(city_code, image_data):
                            success_count += 1
                        else:
                            failure_count += 1
                    else:
                        logging.error(f"❌ HTTP {response.status} for NASA image {city_code}")
                        failure_count += 1

            except Exception as e:
                logging.error(f"❌ NASA image error for {city_code}: {e}")
                failure_count += 1

        logging.info(f'✅ NASA image collection completed: {success_count}/{len(cities_data)} successful, {failure_count} failed')

    except Exception as e:
        logging.error(f"❌ Critical error in collect_nasa_images: {str(e)}")
