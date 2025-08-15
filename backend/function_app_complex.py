import logging
import datetime
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import requests
import pyodbc
from azure.storage.blob import BlobServiceClient
from bs4 import BeautifulSoup
from PIL import Image
from io import BytesIO
from apng import APNG, PNG
import gc  # For memory management
from typing import List, Tuple, Optional

# Global session for HTTP request reuse
session = requests.Session()
session.timeout = (10, 30)  # (connection, read) timeouts

app = func.FunctionApp()

@app.function_name("health_check")
@app.route(route="health")
def health_check(req: func.HttpRequest) -> func.HttpResponse:
    """Health check endpoint."""
    logging.info('Health check endpoint called')
    return func.HttpResponse(
        "WeatherCrawler is running! Functions are working properly.",
        status_code=200
    )

# ==================== HELPER FUNCTIONS ====================
def process_city_weather(cursor, apikey: str, city_code: str, city_name: str, latitude: float, longitude: float) -> bool:
    """Fetch current weather for a city and return data tuple. Returns success status."""
    try:
        api_call = (
            f"https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}"
            f"&appid={apikey}&lang=es&units=metric"
        )

        response = session.get(api_call, timeout=(5, 15))
        response.raise_for_status()
        data = response.json()

        # Optimized data extraction using dict comprehension and safe gets
        weather_data = {
            'coord_lon': data["coord"]["lon"],
            'coord_lat': data["coord"]["lat"],
            'weather_id': data["weather"][0]["id"],
            'weather_main': data["weather"][0]["main"],
            'weather_description': data["weather"][0]["description"],
            'weather_icon': data["weather"][0]["icon"],
            'base': data.get("base"),
            'main_temp': data["main"]["temp"],
            'main_feels_like': data["main"]["feels_like"],
            'main_pressure': data["main"]["pressure"],
            'main_humidity': data["main"]["humidity"],
            'main_temp_min': data["main"]["temp_min"],
            'main_temp_max': data["main"]["temp_max"],
            'main_sea_level': data["main"].get("sea_level"),
            'main_grnd_level': data["main"].get("grnd_level"),
            'visibility': data.get("visibility"),
            'wind_speed': data["wind"]["speed"],
            'wind_deg': data["wind"]["deg"],
            'wind_gust': data["wind"].get("gust"),
            'clouds_all': data["clouds"]["all"],
            'rain_1h': data.get("rain", {}).get("1h"),
            'rain_3h': data.get("rain", {}).get("3h"),
            'dt': data["dt"],
            'sys_country': data["sys"]["country"],
            'sys_sunrise': data["sys"]["sunrise"],
            'sys_sunset': data["sys"]["sunset"],
            'timezone': data["timezone"],
            'city_id': data["id"]
        }

        # Optimized single-line insert with parameterized values
        insert_query = '''
                INSERT INTO weather.WeatherData (
                    Coord_Lon, Coord_Lat, Weather_Id, Weather_Main, Weather_Description, 
                    Weather_Icon, Base, Main_Temp, Main_Feels_Like, Main_Pressure, 
                    Main_Humidity, Main_Temp_Min, Main_Temp_Max, Main_Sea_Level, 
                    Main_Grnd_Level, Visibility, Wind_Speed, Wind_Deg, Wind_Gust, 
                    Clouds_All, Rain_1h, Rain_3h, Dt, Sys_Country, Sys_Sunrise, 
                    Sys_Sunset, Timezone, Id, Name, CityCode, Date_gt,date_sunrise,date_sunset
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time',
                DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time',
                DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time')
        '''

        cursor.execute(insert_query, (
            weather_data['coord_lon'], weather_data['coord_lat'], weather_data['weather_id'], 
            weather_data['weather_main'], weather_data['weather_description'], weather_data['weather_icon'], 
            weather_data['base'], weather_data['main_temp'], weather_data['main_feels_like'], 
            weather_data['main_pressure'], weather_data['main_humidity'], weather_data['main_temp_min'], 
            weather_data['main_temp_max'], weather_data['main_sea_level'], weather_data['main_grnd_level'], 
            weather_data['visibility'], weather_data['wind_speed'], weather_data['wind_deg'], 
            weather_data['wind_gust'], weather_data['clouds_all'], weather_data['rain_1h'], 
            weather_data['rain_3h'], weather_data['dt'], weather_data['sys_country'], 
            weather_data['sys_sunrise'], weather_data['sys_sunset'], weather_data['timezone'], 
            weather_data['city_id'], city_name, city_code, weather_data['dt'], 
            weather_data['sys_sunrise'], weather_data['sys_sunset']
        ))

        return True

    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to get weather data for {city_name}: {e}")
        return False
    except Exception as e:
        logging.error(f"Database error for {city_name}: {e}")
        return False


def process_city_nasa(blob_service_client: BlobServiceClient, container_name: str, icon_url: str, 
                     city_code: str, latitude: float, longitude: float) -> bool:
    """Fetch GOES image for a city, overlay an icon, upload, and refresh animation. Returns success status."""
    try:
        date_img = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        blob_name = f"{city_code}/{date_img}.jpg"

        image_page_url = (
            "https://weather.ndc.nasa.gov/cgi-bin/get-abi?"
            f"satellite=GOESEastfullDiskband13&lat={latitude}&lon={longitude}&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
        )

        response = session.get(image_page_url, timeout=(10, 30))
        if response.status_code != 200:
            logging.error(f"Failed to fetch page for {city_code}. Status code: {response.status_code}")
            return False

        soup = BeautifulSoup(response.text, 'html.parser')
        img_tag = soup.find('img')
        if not img_tag or 'src' not in img_tag.attrs:
            logging.error(f"No image tag found for {city_code}.")
            return False

        img_url = "https://weather.ndc.nasa.gov" + img_tag['src']
        img_response = session.get(img_url, timeout=(15, 45))
        if img_response.status_code != 200:
            logging.error(f"Failed to fetch image from {img_url}. Status code: {img_response.status_code}")
            return False

        image_data = img_response.content
        modified_image_data = add_icon_to_image(image_data, icon_url)
        if modified_image_data is None:
            logging.error(f"Image modification failed for {city_code}.")
            return False

        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
        blob_client.upload_blob(modified_image_data, blob_type="BlockBlob", overwrite=True)
        logging.info(f"Image uploaded to {container_name}/{blob_name}")

        # Only update animation every 4th image to reduce processing load
        current_minute = datetime.datetime.now().minute
        if current_minute % 60 == 0:  # Update animation only on the hour
            generate_animation_for_city(city_code, blob_service_client, container_name)

        return True

    except Exception as e:
        logging.error(f"Error processing NASA GOES image for city {city_code}: {str(e)}")
        return False


def add_icon_to_image(image_data, icon_url):
    """Add a marker icon to the center of a weather satellite image."""
    try:
        main_image = Image.open(BytesIO(image_data))
        
        icon_response = requests.get(icon_url)
        if icon_response.status_code == 200:
            icon_image = Image.open(BytesIO(icon_response.content))
            
            main_width, main_height = main_image.size
            icon_position = ((main_width - 19) // 2, (main_height // 2)-26)
            
            main_image.paste(icon_image, icon_position, icon_image)

            # Crop to 400x400 center
            left = (main_width - 400) // 2
            top = (main_height - 400) // 2
            right = (main_width + 400) // 2
            bottom = (main_height + 400) // 2
            main_image = main_image.crop((left, top, right, bottom))

            output_buffer = BytesIO()
            main_image.save(output_buffer, format='JPEG')
            return output_buffer.getvalue()
        else:
            logging.error(f"Failed to fetch icon image from {icon_url}. Status code: {icon_response.status_code}")
            return None
    
    except Exception as e:
        logging.error(f"Error adding icon to image: {str(e)}")
        return None


def generate_animation_for_city(city_code: str, blob_service_client: BlobServiceClient, container_name: str) -> bool:
    """Generate animated PNG from latest images for a city with memory optimization."""
    try:
        logging.info(f"Generating optimized animation for city: {city_code}")
        
        blob_list = blob_service_client.get_container_client(container_name).list_blobs(name_starts_with=city_code)
        blobs = sorted(blob_list, key=lambda b: b.creation_time, reverse=True)
        # Reduce from 15 to 8 images to reduce memory usage
        latest_blobs = blobs[:8]
        
        if not latest_blobs:
            logging.warning(f"No images found for city: {city_code}")
            return False
        
        # Process images one at a time to reduce memory footprint
        apng = APNG()
        
        for i, blob in enumerate(reversed(latest_blobs)):
            try:
                blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob.name)
                image_data = blob_client.download_blob().readall()
                
                # Process image in-place to minimize memory usage
                with Image.open(BytesIO(image_data)) as img:
                    # Convert to PNG format directly in memory
                    png_buffer = BytesIO()
                    img.save(png_buffer, format='PNG', optimize=True)
                    png_buffer.seek(0)
                    
                    # Create PNG frame
                    png_frame = PNG.from_bytes(png_buffer.read())
                    apng.append(png_frame, delay=400)  # Slightly slower animation
                
                # Clear memory after each frame
                del image_data
                if i % 3 == 0:  # Garbage collect every 3 frames
                    gc.collect()
                    
            except Exception as e:
                logging.error(f"Error processing frame {i} for {city_code}: {e}")
                continue
        
        if len(apng.frames) > 0:
            # Save animation with compression
            output_apng = BytesIO()
            apng.save(output_apng)
            animation_data = output_apng.getvalue()
            
            animation_blob_name = f"{city_code}/animation.png"
            blob_client = blob_service_client.get_blob_client(container=container_name, blob=animation_blob_name)
            blob_client.upload_blob(animation_data, blob_type="BlockBlob", overwrite=True)
            logging.info(f"Optimized animation uploaded to {container_name}/{animation_blob_name} ({len(apng.frames)} frames)")
            
            # Clean up
            del animation_data
            gc.collect()
            return True
        else:
            logging.warning(f"No valid frames generated for {city_code}")
            return False
        
    except Exception as e:
        logging.error(f"Error generating animation for city {city_code}: {str(e)}")
        return False


# ==================== MAIN WEATHER FUNCTION ====================
@app.function_name("run_city_batch")
@app.schedule(schedule="0 */15 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def run_city_batch(timer: func.TimerRequest) -> None:
    """Combined function to process weather data and NASA images for all cities."""
    if timer.past_due:
        logging.info('The timer is past due!')

    conn = None
    cursor = None
    try:
        logging.info('Starting city batch processing...')

        # Initialize Azure clients
        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)

        connection_string = secret_client.get_secret("connstr").value
        apikey = secret_client.get_secret("apikey").value

        # Database connection
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        logging.info('Connected to database')

        # Blob storage client
        storage_account_name = "imagefilesclimaguate"
        container_name = "mapimages"
        icon_url = "https://climaguate.com/images/icons/marker.png"
        blob_service_client = BlobServiceClient(
            account_url=f"https://{storage_account_name}.blob.core.windows.net",
            credential=credential,
        )

        # Get all cities
        cursor.execute("SELECT CityCode, CityName, Latitude, Longitude FROM weather.cities;")
        cities = cursor.fetchall()
        logging.info(f'Processing {len(cities)} cities')

        # Counters for success tracking
        weather_success = 0
        nasa_success = 0
        weather_failures = []
        nasa_failures = []

        # Process each city with improved error isolation
        for city in cities:
            city_code = city.CityCode
            city_name = city.CityName
            latitude = city.Latitude
            longitude = city.Longitude

            logging.info(f"Processing {city_code} - {city_name}")

            # Process weather data with isolated error handling
            try:
                if process_city_weather(cursor, apikey, city_code, city_name, latitude, longitude):
                    weather_success += 1
                else:
                    weather_failures.append(city_code)
            except Exception as e:
                logging.error(f"Critical weather processing error for {city_code}: {str(e)}")
                weather_failures.append(city_code)

            # Process NASA satellite image with isolated error handling
            try:
                if process_city_nasa(blob_service_client, container_name, icon_url, city_code, latitude, longitude):
                    nasa_success += 1
                else:
                    nasa_failures.append(city_code)
            except Exception as e:
                logging.error(f"Critical NASA processing error for {city_code}: {str(e)}")
                nasa_failures.append(city_code)

            # Commit database changes every 5 cities to prevent large rollbacks
            if (weather_success + len(weather_failures)) % 5 == 0:
                try:
                    conn.commit()
                    logging.info(f"Database commit successful after {weather_success + len(weather_failures)} cities")
                except Exception as e:
                    logging.error(f"Database commit failed: {e}")

        # Final commit
        conn.commit()
        
        # Summary logging
        logging.info(f'City batch processing completed:')
        logging.info(f'  Weather: {weather_success}/{len(cities)} successful')
        logging.info(f'  NASA: {nasa_success}/{len(cities)} successful')
        
        if weather_failures:
            logging.warning(f'Weather failures: {weather_failures}')
        if nasa_failures:
            logging.warning(f'NASA failures: {nasa_failures}')

    except Exception as e:
        logging.error(f"Error in run_city_batch: {str(e)}")
    finally:
        if conn is not None:
            try:
                if cursor is not None:
                    cursor.close()
            finally:
                conn.close()


# ==================== FORECAST FUNCTION ====================
@app.function_name("get_quarterday_forecast")
@app.schedule(schedule="0 0 */12 * * *", arg_name="quarterDayTimer", run_on_startup=False, use_monitor=False)
def get_quarterday_forecast(quarterDayTimer: func.TimerRequest) -> None:
    """Get quarter-day weather forecasts for all cities."""
    if quarterDayTimer.past_due:
        logging.info('The timer is past due!')

    conn = None
    try:
        logging.info('Starting quarter-day forecast processing...')
        
        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)

        connection_string = secret_client.get_secret("connstr").value
        apikey = secret_client.get_secret("MapsApiKey").value

        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()

        # Atomic lock to prevent duplicate runs
        run_time = datetime.datetime.utcnow().replace(minute=0, second=0, microsecond=0)

        try:
            cursor.execute(
                "INSERT INTO JobRunLock (RunTimeUtc, StartedAt, Status) VALUES (?, ?, ?)",
                (run_time, datetime.datetime.utcnow(), 'Started')
            )
            conn.commit()
            logging.info(f"[LOCK] Acquired lock for job at {run_time} UTC")
        except Exception as e:
            if "PRIMARY KEY" in str(e) or "duplicate" in str(e).lower():
                logging.warning(f"[LOCK] Job for {run_time} UTC already processed, skipping")
                cursor.close()
                conn.close()
                return
            else:
                logging.error(f"[LOCK] Unexpected error: {str(e)}")
                raise

        # Get cities and process forecasts with batch optimization
        cursor.execute("SELECT CityCode, Latitude, Longitude FROM weather.cities;")
        cities = cursor.fetchall()
        
        success_count = 0
        failure_count = 0
        failed_cities = []

        for city in cities:
            city_code = city.CityCode
            lat = city.Latitude
            lon = city.Longitude

            api_url = (
                f"https://atlas.microsoft.com/weather/forecast/quarterDay/json"
                f"?api-version=1.1&query={lat},{lon}&duration=1&subscription-key={apikey}&language=es-419"
            )

            try:
                response = session.get(api_url, timeout=(10, 30))
                response.raise_for_status()
                forecast_data = response.json()

                forecasts = forecast_data.get("forecasts", [])
                city_forecast_count = 0

                for forecast in forecasts:
                    try:
                        insert_query = '''
                        INSERT INTO WeatherForecast (
                            CityCode, ForecastDate, EffectiveDate, Quarter,
                            IconPhrase, Phrase,
                            TemperatureMin, TemperatureMax, TemperatureAvg,
                            RealFeelMin, RealFeelMax, RealFeelAvg,
                            DewPoint, RelativeHumidity,
                            WindDirectionDegrees, WindDirectionDescription, WindSpeed,
                            WindGustDirectionDegrees, WindGustDirectionDescription, WindGustSpeed,
                            Visibility, CloudCover,
                            HasPrecipitation, PrecipitationType, PrecipitationIntensity,
                            PrecipitationProbability, ThunderstormProbability,
                            TotalLiquid, Rain
                        ) VALUES (
                            ?, 
                            SYSDATETIMEOFFSET() AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time',  
                            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                        )
                        '''
                        cursor.execute(insert_query, (
                            city_code,
                            forecast.get("effectiveDate"),
                            forecast.get("quarter"),
                            forecast.get("iconPhrase"),
                            forecast.get("shortPhrase"),
                            forecast.get("temperature", {}).get("minimum", {}).get("value"),
                            forecast.get("temperature", {}).get("maximum", {}).get("value"),
                            forecast.get("temperature", {}).get("value"),
                            forecast.get("realFeelTemperature", {}).get("minimum", {}).get("value"),
                            forecast.get("realFeelTemperature", {}).get("maximum", {}).get("value"),
                            forecast.get("realFeelTemperature", {}).get("value"),
                            forecast.get("dewPoint", {}).get("value"),
                            forecast.get("relativeHumidity"),
                            forecast.get("wind", {}).get("direction", {}).get("degrees"),
                            forecast.get("wind", {}).get("direction", {}).get("localizedDescription"),
                            forecast.get("wind", {}).get("speed", {}).get("value"),
                            forecast.get("windGust", {}).get("direction", {}).get("degrees"),
                            forecast.get("windGust", {}).get("direction", {}).get("localizedDescription"),
                            forecast.get("windGust", {}).get("speed", {}).get("value"),
                            forecast.get("visibility", {}).get("value"),
                            forecast.get("cloudCover"),
                            forecast.get("hasPrecipitation"),
                            forecast.get("precipitationType"),
                            forecast.get("precipitationIntensity"),
                            forecast.get("precipitationProbability"),
                            forecast.get("thunderstormProbability"),
                            forecast.get("totalLiquid", {}).get("value"),
                            forecast.get("rain", {}).get("value")
                        ))
                        city_forecast_count += 1
                    except Exception as e:
                        logging.error(f"Database insert error for {city_code} forecast: {e}")

                success_count += 1
                logging.info(f"✅ {city_code}: {city_forecast_count} forecasts processed")
                
                # Commit every 3 cities to prevent large rollbacks
                if success_count % 3 == 0:
                    conn.commit()

            except requests.exceptions.RequestException as e:
                logging.error(f"API error for {city_code}: {e}")
                failure_count += 1
                failed_cities.append(city_code)
            except Exception as e:
                logging.error(f"Processing error for {city_code}: {e}")
                failure_count += 1
                failed_cities.append(city_code)

        conn.commit()
        
        # Mark as completed
        cursor.execute("UPDATE JobRunLock SET Status = ? WHERE RunTimeUtc = ?", ('Completed', run_time))
        conn.commit()
        
        # Summary logging
        logging.info(f'Quarter-day forecast processing completed:')
        logging.info(f'  Success: {success_count}/{len(cities)} cities')
        logging.info(f'  Failures: {failure_count}/{len(cities)} cities')
        
        if failed_cities:
            logging.warning(f'Failed cities: {failed_cities}')

    except Exception as e:
        logging.error(f"Error in get_quarterday_forecast: {str(e)}")
    finally:
        if conn:
            cursor.close()
            conn.close()