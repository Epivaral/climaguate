import logging

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

@app.schedule(schedule="0 */15 * * * *", arg_name="myTimer", run_on_startup=True,
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
                api_call = f"https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}&appid={apikey}&lang=es&units=metric"

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
                    Sys_Sunset, Timezone, Id, Name, CityCode, Date_gt,date_sunrise,date_sunset
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time',
                DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time',
                DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time')
        '''

                # Insert data
                cursor.execute(insert_query, (
                    coord_lon, coord_lat, weather_id, weather_main, weather_description,
                    weather_icon, base, main_temp, main_feels_like, main_pressure,
                    main_humidity, main_temp_min, main_temp_max, main_sea_level,
                    main_grnd_level, visibility, wind_speed, wind_deg, wind_gust,
                    clouds_all, rain_1h, rain_3h, dt, sys_country, sys_sunrise,
                    sys_sunset, timezone, city_id, city_name, city_code, dt, sys_sunrise, sys_sunset
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


#--------------------------------------------
#get images

@app.schedule(schedule="0 */15 * * * *", arg_name="nasaTimer", run_on_startup=True,
              use_monitor=False) 

def get_nasa_goes(nasaTimer: func.TimerRequest) -> None:
    
    storage_account_name = "imagefilesclimaguate"
    container_name = "mapimages"
    blob_name = "placeholder_image.jpg"


    icon_url = "https://climaguate.com/images/icons/marker.png"  # Replace with your icon URL

    try:
        logging.info('Starting the process to retrieve secrets from Azure Key Vault.')

        # Get the connection string and API key from Azure Key Vault
        credential = DefaultAzureCredential()
        secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)
        
        connection_string = secret_client.get_secret("connstr").value
        logging.info('Successfully retrieved the connection string from Azure Key Vault.')

        # azure sql DB
        # Connect to the SQL database
        logging.info('Connecting to the SQL database.')
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        logging.info('Successfully connected to the SQL database.')

        # Query the weather.cities table
        logging.info('Executing SQL query to fetch city details.')
        cursor.execute("SELECT CityCode, Latitude, Longitude FROM weather.cities;")
        
        # Fetch all rows from the query
        rows = cursor.fetchall()
        logging.info('Successfully fetched city details from the database.')

        # For each city, log the city details and call the weather API
        for row in rows:
            city_code = row.CityCode
            latitude = row.Latitude
            longitude = row.Longitude
            logging.info(f"City Code: {city_code}, Latitude: {latitude}, Longitude: {longitude}")

            date_img = datetime.datetime.now().strftime("%Y%m%d%H%M%S")

            blob_name = f"{city_code}/{date_img}.jpg"

            image_page_url = f"https://weather.ndc.nasa.gov/cgi-bin/get-abi?satellite=GOESEastfullDiskband13&lat={latitude}&lon={longitude}&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
            
            
            # Fetch the HTML page from the URL
            response = requests.get(image_page_url)
            if response.status_code == 200:
                html_content = response.text
                
                # Parse the HTML to extract the image URL
                soup = BeautifulSoup(html_content, 'html.parser')
                img_tag = soup.find('img')
                if img_tag and 'src' in img_tag.attrs:
                    img_url = "https://weather.ndc.nasa.gov" + img_tag['src']
                    
                    # Fetch the image
                    img_response = requests.get(img_url)
                    if img_response.status_code == 200:
                        image_data = img_response.content
                        
                        
                        modified_image_data = add_icon_to_image(image_data, icon_url)

                        # Use Managed Identity to connect to Azure Blob Storage
                        credential = DefaultAzureCredential()
                        blob_service_client = BlobServiceClient(account_url=f"https://{storage_account_name}.blob.core.windows.net", credential=credential)
                        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)

                        # Upload the image
                        blob_client.upload_blob(modified_image_data, blob_type="BlockBlob", overwrite=True)
                        logging.info(f"Image uploaded to {container_name}/{blob_name}")


                        generate_animation_for_city(city_code, blob_service_client, container_name)
                    else:
                        logging.error(f"Failed to fetch image from {img_url}. Status code: {img_response.status_code}")
                else:
                    logging.error("No image tag found in the HTML response.")
            else:
                logging.error(f"Failed to fetch page. Status code: {response.status_code}")

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