import logging
import datetime
import os
import json

import azure.functions as func

# Only import built-in and azure-functions modules at the top level
# Move problematic imports inside functions to avoid registration issues

app = func.FunctionApp()

# -------------------- Helpers --------------------

def get_cities_from_api():
    """Fetch cities from Data API Builder endpoint using urllib."""
    from urllib.request import urlopen, Request
    from urllib.error import URLError, HTTPError
    
    try:
        api_url = "https://climaguate.com/data-api/rest/GetCities"
        
        request = Request(api_url)
        request.add_header('User-Agent', 'ClimaguateWeatherApp/1.0')
        
        with urlopen(request, timeout=10) as response:
            if response.status == 200:
                data = json.loads(response.read().decode('utf-8'))
                cities_list = data.get('value', [])
                
                logging.info(f"✅ Loaded {len(cities_list)} cities from API with coordinates.")
                return cities_list
            else:
                logging.error(f"❌ HTTP {response.status} from cities API")
                return []
                
    except Exception as e:
        logging.error(f"❌ Error fetching cities: {e}")
        return []


def process_city_weather(cursor, apikey: str, city_code: str, city_name: str, latitude: float, longitude: float) -> None:
    """Fetch current weather for a city and insert into DB using provided cursor."""
    import requests  # Import inside function
    
    try:
        api_call = (
            f"https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}"
            f"&appid={apikey}&lang=es&units=metric"
        )

        response = requests.get(api_call)
        response.raise_for_status()
        data = response.json()

        coord_lon = data["coord"]["lon"]
        coord_lat = data["coord"]["lat"]
        weather_id = data["weather"][0]["id"]
        weather_main = data["weather"][0]["main"]
        weather_description = data["weather"][0]["description"]
        weather_icon = data["weather"][0]["icon"]
        base = data.get("base")
        main_temp = data["main"]["temp"]
        main_feels_like = data["main"]["feels_like"]
        main_pressure = data["main"]["pressure"]
        main_humidity = data["main"]["humidity"]
        main_temp_min = data["main"]["temp_min"]
        main_temp_max = data["main"]["temp_max"]
        main_sea_level = data["main"].get("sea_level")
        main_grnd_level = data["main"].get("grnd_level")
        visibility = data.get("visibility")
        wind_speed = data["wind"]["speed"]
        wind_deg = data["wind"]["deg"]
        wind_gust = data["wind"].get("gust")
        clouds_all = data["clouds"]["all"]
        rain_1h = data.get("rain", {}).get("1h")
        rain_3h = data.get("rain", {}).get("3h")
        dt = data["dt"]
        sys_country = data["sys"]["country"]
        sys_sunrise = data["sys"]["sunrise"]
        sys_sunset = data["sys"]["sunset"]
        timezone = data["timezone"]
        city_id = data["id"]

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

        cursor.execute(
            insert_query,
            (
                coord_lon,
                coord_lat,
                weather_id,
                weather_main,
                weather_description,
                weather_icon,
                base,
                main_temp,
                main_feels_like,
                main_pressure,
                main_humidity,
                main_temp_min,
                main_temp_max,
                main_sea_level,
                main_grnd_level,
                visibility,
                wind_speed,
                wind_deg,
                wind_gust,
                clouds_all,
                rain_1h,
                rain_3h,
                dt,
                sys_country,
                sys_sunrise,
                sys_sunset,
                timezone,
                city_id,
                city_name,
                city_code,
                dt,
                sys_sunrise,
                sys_sunset,
            ),
        )

    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to get weather data for {city_name}: {e}")


def process_city_nasa(
    blob_service_client,
    container_name: str,
    icon_url: str,
    city_code: str,
    latitude: float,
    longitude: float,
) -> None:
    """Fetch GOES image for a city, overlay an icon, upload, and refresh animation."""
    import requests  # Import inside function
    from bs4 import BeautifulSoup
    
    try:
        date_img = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        blob_name = f"{city_code}/{date_img}.jpg"

        image_page_url = (
            "https://weather.ndc.nasa.gov/cgi-bin/get-abi?"
            f"satellite=GOESEastfullDiskband13&lat={latitude}&lon={longitude}&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
        )

        response = requests.get(image_page_url)
        if response.status_code == 200:
            html_content = response.text

            soup = BeautifulSoup(html_content, "html.parser")
            img_tag = soup.find("img")
            if img_tag and "src" in img_tag.attrs:
                img_url = "https://weather.ndc.nasa.gov" + img_tag["src"]

                img_response = requests.get(img_url)
                if img_response.status_code == 200:
                    image_data = img_response.content

                    # Add icon to the image
                    modified_image_data = add_icon_to_image(image_data, icon_url)

                    # Upload to blob storage
                    blob_client = blob_service_client.get_blob_client(
                        container=container_name, blob=blob_name
                    )
                    blob_client.upload_blob(
                        modified_image_data, blob_type="BlockBlob", overwrite=True
                    )
                    logging.info(f"Image uploaded to {container_name}/{blob_name}")

                    # Generate animation
                    generate_animation_for_city(
                        city_code, blob_service_client, container_name
                    )

    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to get NASA image for {city_code}: {e}")


@app.schedule(schedule="0 */15 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def run_city_batch(timer: func.TimerRequest) -> None:
    # Import problematic modules inside the function to avoid registration issues
    import pyodbc
    from azure.storage.blob import BlobServiceClient
    
    if timer.past_due:
        logging.info('The timer is past due!')

    conn = None
    cursor = None
    try:
        logging.info('Starting the process to retrieve configuration from environment variables.')

        # Use environment variables instead of Key Vault (Azure Functions auto-maps Key Vault to env vars)
        connection_string = os.environ.get("connstr")
        apikey = os.environ.get("apikey")
        
        if not connection_string or not apikey:
            raise ValueError("Missing required environment variables: connstr and/or apikey")

        # Connect to SQL once
        logging.info('Connecting to the SQL database.')
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        logging.info('Successfully connected to the SQL database.')

        # Prepare Blob client once (using managed identity)
        storage_account_name = "imagefilesclimaguate"
        container_name = "mapimages"
        icon_url = "https://climaguate.com/images/icons/marker.png"
        
        # Use managed identity for blob storage (Azure Functions built-in capability)
        blob_service_client = BlobServiceClient(account_url=f"https://{storage_account_name}.blob.core.windows.net")

        # Fetch cities from Data API instead of direct database query
        logging.info('Fetching city details from Data API.')
        cities_data = get_cities_from_api()
        
        if not cities_data:
            logging.error('❌ Failed to fetch cities from API - aborting batch processing')
            return
            
        logging.info(f'Successfully fetched {len(cities_data)} cities from API.')

        # Process each city
        for city in cities_data:
            city_code = city.get('CityCode')
            city_name = city.get('CityName')
            latitude = city.get('Latitude')
            longitude = city.get('Longitude')
            
            # Skip cities with missing data
            if not city_code or not city_name or latitude is None or longitude is None:
                logging.warning(f"⚠️ Skipping city with missing data: {city}")
                continue

            logging.info(f"Processing {city_code} - {city_name} ({latitude}, {longitude})")

            # Weather data -> DB
            try:
                process_city_weather(cursor, apikey, city_code, city_name, latitude, longitude)
            except Exception as e:
                logging.error(f"Weather processing failed for {city_code}: {str(e)}")

            # NASA GOES image -> Blob + animation
            try:
                process_city_nasa(blob_service_client, container_name, icon_url, city_code, latitude, longitude)
            except Exception as e:
                logging.error(f"NASA processing failed for {city_code}: {str(e)}")

        # Commit DB writes once
        conn.commit()

    except pyodbc.Error as e:
        logging.error(f"Database connection or query error: {str(e)}")
    except Exception as e:
        logging.error(f"An error occurred in run_city_batch: {str(e)}")
    finally:
        if conn is not None:
            try:
                if cursor is not None:
                    cursor.close()
            finally:
                conn.close()


#--------------------------------------------
# get images helpers remain below
    
    

def add_icon_to_image(image_data, icon_url):
    import requests  # Import inside function
    from PIL import Image
    from io import BytesIO
    
    try:
        # Open the main image using Pillow
        main_image = Image.open(BytesIO(image_data))
        
        # Load the icon image
        icon_response = requests.get(icon_url)
        if icon_response.status_code == 200:
            icon_image = Image.open(BytesIO(icon_response.content))
            
            # Calculate the position to center the icon on the main image
            main_width, main_height = main_image.size
            icon_position = ((main_width - 19) // 2, (main_height // 2)-26)
            
            # Paste the icon onto the main image
            main_image.paste(icon_image, icon_position, icon_image)
            
            # Convert back to bytes
            output = BytesIO()
            main_image.save(output, format='JPEG')
            return output.getvalue()
        else:
            return image_data  # Return original if icon failed
    except Exception as e:
        logging.error(f"Error adding icon to image: {str(e)}")
        return image_data  # Return original if error



def generate_animation_for_city(city_code: str, blob_service_client, container_name: str) -> bool:
    """Generate animated PNG from latest images for a city with memory optimization."""
    from PIL import Image
    from io import BytesIO
    from apng import APNG, PNG
    
    try:
        # List the blobs for this city, sorted by modification date (most recent first)
        blobs = []
        for blob in blob_service_client.get_container_client(container_name).list_blobs(name_starts_with=f"{city_code}/"):
            if blob.name.endswith('.jpg'):
                blobs.append(blob)
        
        # Sort by last modified descending (newest first)
        blobs.sort(key=lambda x: x.last_modified, reverse=True)
        
        if len(blobs) < 2:
            logging.info(f"Not enough images for animation for city {city_code} (found {len(blobs)})")
            return False

        # Take up to the latest 10 images
        blobs_to_use = blobs[:10]
        
        # Create APNG from images
        files = []
        for i, blob in enumerate(blobs_to_use):
            try:
                # Download blob
                blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob.name)
                blob_data = blob_client.download_blob().readall()
                
                # Load as PIL Image and resize if needed
                img = Image.open(BytesIO(blob_data))
                
                # Resize to a reasonable size for web (optional, adjust as needed)
                if img.size[0] > 600 or img.size[1] > 600:
                    img.thumbnail((600, 600), Image.Resampling.LANCZOS)
                
                # Convert to PNG bytes
                png_bytes = BytesIO()
                img.save(png_bytes, format='PNG')
                png_bytes.seek(0)
                
                # Add to APNG with delay (500ms per frame)
                files.append(PNG.from_bytes(png_bytes.getvalue()))
                
            except Exception as e:
                logging.warning(f"Failed to process blob {blob.name} for animation: {e}")
                continue
        
        if len(files) < 2:
            logging.warning(f"Not enough valid images processed for city {city_code} animation.")
            return False
            
        # Create animation with delay
        apng = APNG()
        for png in files:
            apng.append(png, delay=500)  # 500ms delay between frames
        
        # Save animation to bytes
        animation_data = BytesIO()
        apng.save(animation_data)
        animation_bytes = animation_data.getvalue()
        
        if len(animation_bytes) == 0:
            logging.error(f"Generated animation is empty for city {city_code}")
            return False
        
        # Upload the animation
        animation_blob_name = f"{city_code}/animation.png"
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=animation_blob_name)
        blob_client.upload_blob(animation_bytes, blob_type="BlockBlob", overwrite=True)
        logging.info(f"Animation uploaded to {container_name}/{animation_blob_name}")
        
        return True
        
    except Exception as e:
        logging.error(f"Error generating animation for city {city_code}: {str(e)}")
        return False


# -------------------------------------------------------
# Quarter-day forecast function

@app.schedule(schedule="0 0 */12 * * *", arg_name="quarterDayTimer", run_on_startup=False, use_monitor=False)
def get_quarterday_forecast(quarterDayTimer: func.TimerRequest) -> None:
    # Import problematic modules inside the function
    import pyodbc
    import requests  # Add requests import
    
    if quarterDayTimer.past_due:
        logging.info('The timer is past due!')

    conn = None
    try:
        logging.info('Starting forecast process with environment variables.')
        
        # Use environment variables instead of Key Vault
        connection_string = os.environ.get("connstr")
        apikey = os.environ.get("azuremapskey")  # Note: different API key for forecasts
        
        if not connection_string or not apikey:
            raise ValueError("Missing required environment variables: connstr and/or azuremapskey")

        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()

        # Fetch cities from Data API instead of direct database query
        logging.info('Fetching cities for forecast processing from Data API.')
        cities_data = get_cities_from_api()
        
        if not cities_data:
            logging.error('❌ Failed to fetch cities from API for forecast processing')
            return

        for city in cities_data:
            city_code = city.get('CityCode')
            city_name = city.get('CityName') 
            lat = city.get('Latitude')
            lon = city.get('Longitude')
            
            # Skip cities with missing data
            if not city_code or not city_name or lat is None or lon is None:
                logging.warning(f"⚠️ Skipping forecast for city with missing data: {city}")
                continue

            api_url = (
                f"https://atlas.microsoft.com/weather/forecast/quarterDay/json"
                f"?api-version=1.1&query={lat},{lon}&duration=1&subscription-key={apikey}&language=es-419"
            )

            try:
                response = requests.get(api_url)
                response.raise_for_status()
                forecast_data = response.json()

                forecasts = forecast_data.get("forecasts", [])

                for forecast in forecasts:
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

            except requests.exceptions.RequestException as e:
                logging.error(f"API error for {city_code}: {e}")

        conn.commit()

        # Optionally mark as completed
        # cursor.execute("UPDATE JobRunLock SET Status = ? WHERE RunTimeUtc = ?", ('Completed', run_time))
        # conn.commit()

    except Exception as e:
        logging.error(f"An error occurred in get_quarterday_forecast: {str(e)}")
    finally:
        if conn is not None:
            conn.close()
