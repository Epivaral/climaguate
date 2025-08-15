
import logging
import datetime

import azure.functions as func

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import requests
import pyodbc

from azure.storage.blob import BlobServiceClient
from bs4 import BeautifulSoup
import datetime

from PIL import Image
from io import BytesIO
from apng import APNG, PNG


app = func.FunctionApp()

# -------------------- Helpers --------------------
def process_city_weather(cursor, apikey: str, city_code: str, city_name: str, latitude: float, longitude: float) -> None:
    """Fetch current weather for a city and insert into DB using provided cursor."""
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
    blob_service_client: BlobServiceClient,
    container_name: str,
    icon_url: str,
    city_code: str,
    latitude: float,
    longitude: float,
) -> None:
    """Fetch GOES image for a city, overlay an icon, upload, and refresh animation."""
    try:
        date_img = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        blob_name = f"{city_code}/{date_img}.jpg"

        image_page_url = (
            "https://weather.ndc.nasa.gov/cgi-bin/get-abi?"
            f"satellite=GOESEastfullDiskband13&lat={latitude}&lon={longitude}&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
        )

        response = requests.get(image_page_url)
        if response.status_code != 200:
            logging.error(f"Failed to fetch page for {city_code}. Status code: {response.status_code}")
            return

        soup = BeautifulSoup(response.text, 'html.parser')
        img_tag = soup.find('img')
        if not img_tag or 'src' not in img_tag.attrs:
            logging.error(f"No image tag found for {city_code}.")
            return

        img_url = "https://weather.ndc.nasa.gov" + img_tag['src']
        img_response = requests.get(img_url)
        if img_response.status_code != 200:
            logging.error(f"Failed to fetch image from {img_url}. Status code: {img_response.status_code}")
            return

        image_data = img_response.content
        modified_image_data = add_icon_to_image(image_data, icon_url)
        if modified_image_data is None:
            logging.error(f"Image modification failed for {city_code}.")
            return

        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
        blob_client.upload_blob(modified_image_data, blob_type="BlockBlob", overwrite=True)
        logging.info(f"Image uploaded to {container_name}/{blob_name}")

        # Update city animation
        generate_animation_for_city(city_code, blob_service_client, container_name)

    except Exception as e:
        logging.error(f"Error processing NASA GOES image for city {city_code}: {str(e)}")


# -------------------- Combined scheduled function --------------------
@app.schedule(schedule="0 */15 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def run_city_batch(timer: func.TimerRequest) -> None:
    if timer.past_due:
        logging.info('The timer is past due!')

    conn = None
    cursor = None
    try:
        logging.info('Starting the process to retrieve secrets from Azure Key Vault.')

        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)

        connection_string = secret_client.get_secret("connstr").value
        apikey = secret_client.get_secret("apikey").value

        # Connect to SQL once
        logging.info('Connecting to the SQL database.')
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        logging.info('Successfully connected to the SQL database')

        # Prepare Blob client once (Managed Identity)
        storage_account_name = "imagefilesclimaguate"
        container_name = "mapimages"
        icon_url = "https://climaguate.com/images/icons/marker.png"
        blob_service_client = BlobServiceClient(
            account_url=f"https://{storage_account_name}.blob.core.windows.net",
            credential=credential,
        )

        # Fetch all cities once
        logging.info('Executing SQL query to fetch city details.')
        cursor.execute("SELECT CityCode, CityName, Latitude, Longitude FROM weather.cities;")
        rows = cursor.fetchall()
        logging.info(f'Successfully fetched {len(rows)} cities from the database.')

        # Process each city
        for row in rows:
            city_code = row.CityCode
            city_name = row.CityName
            latitude = row.Latitude
            longitude = row.Longitude

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

            # Crop the image to a square from the center, approximately 400x400 pixels
            left = (main_width - 400) // 2
            top = (main_height - 400) // 2
            right = (main_width + 400) // 2
            bottom = (main_height + 400) // 2
            main_image = main_image.crop((left, top, right, bottom))

            
            # Save or upload the modified image
            output_buffer = BytesIO()
            main_image.save(output_buffer, format='JPEG')
            modified_image_data = output_buffer.getvalue()
            
            return modified_image_data
        
        else:
            logging.error(f"Failed to fetch icon image from {icon_url}. Status code: {icon_response.status_code}")
            return None
    
    except Exception as e:
        logging.error(f"Error adding icon to image: {str(e)}")
        return None

    

#--------------------------------------------
def generate_animation_for_city(city_code, blob_service_client, container_name):
    try:
        logging.info(f"Generating animation for city: {city_code}")
        
        # List the blobs in the city folder
        blob_list = blob_service_client.get_container_client(container_name).list_blobs(name_starts_with=city_code)
        blobs = sorted(blob_list, key=lambda b: b.creation_time, reverse=True)
        
        # Get the latest 5 blobs
        latest_blobs = blobs[:15]
        
        # Download the latest 15 images
        images = []
        for blob in latest_blobs:
            blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob.name)
            image_data = blob_client.download_blob().readall()
            images.append(Image.open(BytesIO(image_data)))

        # Reverse the order of images
        images.reverse()
        
        # Create an animated PNG (APNG)
        if images:
            apng = APNG()
            for img in images:
                output_buffer = BytesIO()
                img.save(output_buffer, format='PNG')
                output_buffer.seek(0)
                png_frame = PNG.from_bytes(output_buffer.read())
                apng.append(png_frame, delay=300)
            
            output_apng = BytesIO()
            apng.save(output_apng)
            animation_data = output_apng.getvalue()
            
            # Upload the animation
            animation_blob_name = f"{city_code}/animation.png"
            blob_client = blob_service_client.get_blob_client(container=container_name, blob=animation_blob_name)
            blob_client.upload_blob(animation_data, blob_type="BlockBlob", overwrite=True)
            logging.info(f"Animation uploaded to {container_name}/{animation_blob_name}")
        
    except Exception as e:
        logging.error(f"Error generating animation for city {city_code}: {str(e)}")


# -------------------------------------------------------
# Quarter-day forecast function

@app.schedule(schedule="0 0 */12 * * *", arg_name="quarterDayTimer", run_on_startup=False, use_monitor=False)
def get_quarterday_forecast(quarterDayTimer: func.TimerRequest) -> None:
    if quarterDayTimer.past_due:
        logging.info('The timer is past due!')

    conn = None
    try:
        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)

        connection_string = secret_client.get_secret("connstr").value
        apikey = secret_client.get_secret("MapsApiKey").value

        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()

        ### ATOMIC SINGLETON LOCK ###
        run_time = datetime.datetime.utcnow().replace(minute=0, second=0, microsecond=0)

        try:
            cursor.execute(
                "INSERT INTO JobRunLock (RunTimeUtc, StartedAt, Status) VALUES (?, ?, ?)",
                (run_time, datetime.datetime.utcnow(), 'Started')
            )
            conn.commit()
            logging.info(f"[LOCK] Acquired lock for job at {run_time} UTC, proceeding.")
        except Exception as e:
            # This catches duplicate key error if the lock already exists
            if "PRIMARY KEY" in str(e) or "duplicate" in str(e).lower():
                logging.warning(f"[LOCK] Job for {run_time} UTC already processed (lock exists), skipping this execution.")
                cursor.close()
                conn.close()
                return
            else:
                logging.error(f"[LOCK] Unexpected DB error: {str(e)}")
                raise
        ### END ATOMIC SINGLETON LOCK ###

        # Main logic
        cursor.execute("SELECT CityCode, Latitude, Longitude FROM weather.cities;")
        cities = cursor.fetchall()

        for city in cities:
            city_code = city.CityCode
            lat = city.Latitude
            lon = city.Longitude

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
        cursor.execute("UPDATE JobRunLock SET Status = ? WHERE RunTimeUtc = ?", ('Completed', run_time))
        conn.commit()

    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")

    finally:
        if conn:
            cursor.close()
            conn.close()
