import logging
import azure.functions as func

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import requests
import pyodbc

from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
import datetime

app = func.FunctionApp()

@app.schedule(schedule="0 */30 * * * *", arg_name="myTimer", run_on_startup=True,
              use_monitor=False) 
def get_weather_api(myTimer: func.TimerRequest) -> None:
    if myTimer.past_due:
        logging.info('The timer is past due!')

    try:
        logging.info('Starting the process to retrieve secrets from Azure Key Vault.')

        # Get the connection string and API key from Azure Key Vault
        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)
        
        connection_string = secret_client.get_secret("connstr").value
        logging.info('Successfully retrieved the connection string from Azure Key Vault.')
        
        apikey = secret_client.get_secret("apikey").value
        logging.info('Successfully retrieved the API key from Azure Key Vault.')

        # azure sql DB
        # Connect to the SQL database
        logging.info('Connecting to the SQL database.')
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        logging.info('Successfully connected to the SQL database.')

        # Query the weather.cities table
        logging.info('Executing SQL query to fetch city details.')
        cursor.execute("SELECT CityCode, CityName, Latitude, Longitude FROM weather.cities;")
        
        # Fetch all rows from the query
        rows = cursor.fetchall()
        logging.info('Successfully fetched city details from the database.')

        # For each city, log the city details and call the weather API
        for row in rows:
            city_code = row.CityCode
            city_name = row.CityName
            latitude = row.Latitude
            longitude = row.Longitude
            logging.info(f"City Code: {city_code}, City Name: {city_name}, Latitude: {latitude}, Longitude: {longitude}")

            # Call the weather API
            try:
                api_call = f"https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}&appid={apikey}&lang=es"

                response = requests.get(api_call)
                response.raise_for_status()  # This will raise an HTTPError if the HTTP request returned an unsuccessful status code
                data = response.json()

                # Store the weather data in the weather.weatherdata table

                coord_lon = data["coord"]["lon"]
                coord_lat = data["coord"]["lat"]
                weather_id = data["weather"][0]["id"]
                weather_main = data["weather"][0]["main"]
                weather_description = data["weather"][0]["description"]
                weather_icon = data["weather"][0]["icon"]
                base = data["base"]
                main_temp = data["main"]["temp"]
                main_feels_like = data["main"]["feels_like"]
                main_pressure = data["main"]["pressure"]
                main_humidity = data["main"]["humidity"]
                main_temp_min = data["main"]["temp_min"]
                main_temp_max = data["main"]["temp_max"]
                main_sea_level = data["main"].get("sea_level", None)  # Default to None if not present
                main_grnd_level = data["main"].get("grnd_level", None)  # Default to None if not present
                visibility = data.get("visibility", None)
                wind_speed = data["wind"]["speed"]
                wind_deg = data["wind"]["deg"]
                wind_gust = data["wind"].get("gust", None)  # Default to None if not present
                clouds_all = data["clouds"]["all"]
                rain_1h = data.get("rain", {}).get("1h", None) # Default to None if not present
                rain_3h = data.get("rain", {}).get("3h", None) # Default to None if not present
                dt = data["dt"]
                sys_country = data["sys"]["country"]
                sys_sunrise = data["sys"]["sunrise"]
                sys_sunset = data["sys"]["sunset"]
                timezone = data["timezone"]
                city_id = data["id"]

                # Insert statement
                insert_query = '''
                INSERT INTO weather.WeatherData (
                    Coord_Lon, Coord_Lat, Weather_Id, Weather_Main, Weather_Description, 
                    Weather_Icon, Base, Main_Temp, Main_Feels_Like, Main_Pressure, 
                    Main_Humidity, Main_Temp_Min, Main_Temp_Max, Main_Sea_Level, 
                    Main_Grnd_Level, Visibility, Wind_Speed, Wind_Deg, Wind_Gust, 
                    Clouds_All, Rain_1h, Rain_3h, Dt, Sys_Country, Sys_Sunrise, 
                    Sys_Sunset, Timezone, Id, Name, CityCode
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        '''

                # Insert data
                cursor.execute(insert_query, (
                    coord_lon, coord_lat, weather_id, weather_main, weather_description,
                    weather_icon, base, main_temp, main_feels_like, main_pressure,
                    main_humidity, main_temp_min, main_temp_max, main_sea_level,
                    main_grnd_level, visibility, wind_speed, wind_deg, wind_gust,
                    clouds_all, rain_1h, rain_3h, dt, sys_country, sys_sunrise,
                    sys_sunset, timezone, city_id, city_name, city_code
                ))

            except requests.exceptions.RequestException as e:
                logging.error(f"Failed to get weather data for {city_name}: {e}")

    except pyodbc.Error as e:
        logging.error(f"Database connection or query error: {str(e)}")

    except Exception as e:
        logging.error(f"An error occurred: {str(e)}")

    finally:
        # Always commit and close, even if an error occurs
        if conn is not None:
            conn.commit()
            if cursor is not None:
                cursor.close()
            conn.close()


# @app.schedule(schedule="0 */30 * * * *", arg_name="nasaTimer", run_on_startup=True,
#               use_monitor=False) 

# def get_nasa_goes(nasaTimer: func.TimerRequest) -> None:
# image_page_url = "https://weather.ndc.nasa.gov/cgi-bin/get-abi?satellite=GOESEastfullDiskband13&lat=14.6349&lon=-90.5069&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
#     storage_account_name = "imagefilesclimaguate"
#     container_name = "mapimages"
#     blob_name = "satellite_image.png"
    
#     # Fetch the HTML page from the URL
#     response = requests.get(image_page_url)
#     if response.status_code == 200:
#         html_content = response.text
        
#         # Parse the HTML to extract the image URL
#         soup = BeautifulSoup(html_content, 'html.parser')
#         img_tag = soup.find('img')
#         if img_tag and 'src' in img_tag.attrs:
#             img_url = "https://weather.ndc.nasa.gov" + img_tag['src']
            
#             # Fetch the image
#             img_response = requests.get(img_url)
#             if img_response.status_code == 200:
#                 image_data = img_response.content
                
#                 # Use Managed Identity to connect to Azure Blob Storage
#                 credential = DefaultAzureCredential()
#                 blob_service_client = BlobServiceClient(account_url=f"https://{storage_account_name}.blob.core.windows.net", credential=credential)
#                 blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)

#                 # Upload the image
#                 blob_client.upload_blob(image_data, blob_type="BlockBlob", overwrite=True)
#                 logging.info(f"Image uploaded to {container_name}/{blob_name}")
#             else:
#                 logging.error(f"Failed to fetch image from {img_url}. Status code: {img_response.status_code}")
#         else:
#             logging.error("No image tag found in the HTML response.")
#     else:
#         logging.error(f"Failed to fetch page. Status code: {response.status_code}")

#     if mytimer.past_due:
#         logging.info('The timer is past due!')

#     logging.info('Python timer trigger function ran at %s', utc_timestamp)
    

