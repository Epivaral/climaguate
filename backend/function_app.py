import logging
import datetime
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import pyodbc
import requests

app = func.FunctionApp()

# Global session for HTTP request reuse
session = requests.Session()
session.timeout = (10, 30)


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
    """Collect weather data for all cities - INLINE CODE NO IMPORTS."""
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
        logging.info(f'Processing {len(cities)} cities for weather data')

        success_count = 0
        failure_count = 0

        # Process each city - INLINE WEATHER PROCESSING
        for city in cities:
            city_code = city.CityCode
            city_name = city.CityName
            latitude = city.Latitude
            longitude = city.Longitude

            logging.info(f"Processing weather for {city_code} - {city_name}")

            try:
                # INLINE WEATHER API CALL
                api_call = (
                    f"https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}"
                    f"&appid={apikey}&lang=es&units=metric"
                )

                response = session.get(api_call, timeout=(5, 15))
                response.raise_for_status()
                data = response.json()

                # Extract key weather data
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
                    'dt': data["dt"],
                    'sys_country': data["sys"]["country"],
                    'sys_sunrise': data["sys"]["sunrise"],
                    'sys_sunset': data["sys"]["sunset"],
                    'city_id': data["id"]
                }

                # INLINE DATABASE INSERT
                insert_query = '''
                    INSERT INTO weather.WeatherData (
                        Coord_Lon, Coord_Lat, Weather_Id, Weather_Main, Weather_Description, 
                        Weather_Icon, Base, Main_Temp, Main_Feels_Like, Main_Pressure, 
                        Main_Humidity, Dt, Sys_Country, Sys_Sunrise, 
                        Sys_Sunset, Id, Name, CityCode, Date_gt, date_sunrise, date_sunset
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                    DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time',
                    DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time',
                    DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time')
                '''

                cursor.execute(insert_query, (
                    weather_data['coord_lon'], weather_data['coord_lat'], weather_data['weather_id'], 
                    weather_data['weather_main'], weather_data['weather_description'], weather_data['weather_icon'], 
                    weather_data['base'], weather_data['main_temp'], weather_data['main_feels_like'], 
                    weather_data['main_pressure'], weather_data['main_humidity'], weather_data['dt'], 
                    weather_data['sys_country'], weather_data['sys_sunrise'], weather_data['sys_sunset'], 
                    weather_data['city_id'], city_name, city_code, weather_data['dt'], 
                    weather_data['sys_sunrise'], weather_data['sys_sunset']
                ))

                success_count += 1

            except Exception as e:
                logging.error(f"Weather processing error for {city_code}: {str(e)}")
                failure_count += 1

            # Commit every 5 cities
            if (success_count + failure_count) % 5 == 0:
                conn.commit()

        # Final commit and summary
        conn.commit()
        logging.info(f'Weather collection completed: {success_count}/{len(cities)} successful, {failure_count} failed')

    except Exception as e:
        logging.error(f"Error in collect_weather_data: {str(e)}")
    finally:
        if conn:
            conn.close()
