import logging
import datetime
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import pyodbc
from azure.storage.blob import BlobServiceClient

# Import our helper modules
from weather_helpers import process_city_weather, process_forecast_for_city
from nasa_helpers import process_city_nasa

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


# ==================== WEATHER DATA FUNCTION ====================
@app.function_name("collect_weather_data")
@app.schedule(schedule="0 */15 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def collect_weather_data(timer: func.TimerRequest) -> None:
    """Collect weather data for all cities - simplified version."""
    if timer.past_due:
        logging.info('The timer is past due!')

    conn = None
    try:
        logging.info('Starting weather data collection...')

        # Initialize Azure clients
        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)
        apikey = secret_client.get_secret("apikey").value

        # Database connection
        connection_string = secret_client.get_secret("connstr").value
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        logging.info('Connected to database')

        # Get all cities
        cursor.execute("SELECT CityCode, CityName, Latitude, Longitude FROM weather.cities;")
        cities = cursor.fetchall()
        logging.info(f'Processing {len(cities)} cities')

        success_count = 0
        failure_count = 0

        # Process each city
        for city in cities:
            city_code = city.CityCode
            city_name = city.CityName
            latitude = city.Latitude
            longitude = city.Longitude

            logging.info(f"Processing weather for {city_code} - {city_name}")

            try:
                if process_city_weather(cursor, apikey, city_code, city_name, latitude, longitude):
                    success_count += 1
                else:
                    failure_count += 1
            except Exception as e:
                logging.error(f"Weather processing error for {city_code}: {str(e)}")
                failure_count += 1

            # Commit every 5 cities
            if (success_count + failure_count) % 5 == 0:
                conn.commit()

        # Final commit and summary
        conn.commit()
        logging.info(f'Weather collection completed: {success_count}/{len(cities)} successful')

    except Exception as e:
        logging.error(f"Error in collect_weather_data: {str(e)}")
    finally:
        if conn:
            conn.close()


# ==================== NASA IMAGE FUNCTION ====================
@app.function_name("collect_nasa_images")  
@app.schedule(schedule="5 */15 * * * *", arg_name="nasaTimer", run_on_startup=False, use_monitor=False)
def collect_nasa_images(nasaTimer: func.TimerRequest) -> None:
    """Collect NASA satellite images for all cities - simplified version."""
    if nasaTimer.past_due:
        logging.info('The timer is past due!')

    conn = None
    try:
        logging.info('Starting NASA image collection...')

        # Initialize Azure clients
        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)

        # Blob storage client
        storage_account_name = "imagefilesclimaguate"
        container_name = "mapimages"
        icon_url = "https://climaguate.com/images/icons/marker.png"
        blob_service_client = BlobServiceClient(
            account_url=f"https://{storage_account_name}.blob.core.windows.net",
            credential=credential,
        )

        # Get cities from database
        connection_string = secret_client.get_secret("connstr").value
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()

        cursor.execute("SELECT CityCode, CityName, Latitude, Longitude FROM weather.cities;")
        cities = cursor.fetchall()
        logging.info(f'Processing NASA images for {len(cities)} cities')

        success_count = 0
        failure_count = 0

        # Process each city
        for city in cities:
            city_code = city.CityCode
            city_name = city.CityName
            latitude = city.Latitude
            longitude = city.Longitude

            logging.info(f"Processing NASA image for {city_code} - {city_name}")

            try:
                if process_city_nasa(blob_service_client, container_name, icon_url, city_code, latitude, longitude):
                    success_count += 1
                else:
                    failure_count += 1
            except Exception as e:
                logging.error(f"NASA processing error for {city_code}: {str(e)}")
                failure_count += 1

        logging.info(f'NASA image collection completed: {success_count}/{len(cities)} successful')

    except Exception as e:
        logging.error(f"Error in collect_nasa_images: {str(e)}")
    finally:
        if conn:
            conn.close()


# ==================== FORECAST FUNCTION ====================
@app.function_name("collect_forecasts")
@app.schedule(schedule="0 0 */12 * * *", arg_name="forecastTimer", run_on_startup=False, use_monitor=False)
def collect_forecasts(forecastTimer: func.TimerRequest) -> None:
    """Collect quarter-day weather forecasts for all cities - simplified version."""
    if forecastTimer.past_due:
        logging.info('The timer is past due!')

    conn = None
    try:
        logging.info('Starting forecast collection...')
        
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
        except Exception as e:
            if "PRIMARY KEY" in str(e) or "duplicate" in str(e).lower():
                logging.warning(f"Forecast job for {run_time} UTC already processed")
                return
            else:
                raise

        # Get cities and process forecasts
        cursor.execute("SELECT CityCode, Latitude, Longitude FROM weather.cities;")
        cities = cursor.fetchall()
        
        success_count = 0
        failure_count = 0

        for city in cities:
            city_code = city.CityCode
            lat = city.Latitude
            lon = city.Longitude

            try:
                forecast_count = process_forecast_for_city(cursor, apikey, city_code, lat, lon)
                if forecast_count > 0:
                    success_count += 1
                    logging.info(f"✅ {city_code}: {forecast_count} forecasts processed")
                else:
                    failure_count += 1
                
                # Commit every 3 cities
                if (success_count + failure_count) % 3 == 0:
                    conn.commit()

            except Exception as e:
                logging.error(f"Forecast processing error for {city_code}: {e}")
                failure_count += 1

        # Final commit and mark as completed
        conn.commit()
        cursor.execute("UPDATE JobRunLock SET Status = ? WHERE RunTimeUtc = ?", ('Completed', run_time))
        conn.commit()
        
        logging.info(f'Forecast collection completed: {success_count}/{len(cities)} successful')

    except Exception as e:
        logging.error(f"Error in collect_forecasts: {str(e)}")
    finally:
        if conn:
            conn.close()
