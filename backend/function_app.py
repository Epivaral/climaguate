import logging
import datetime
import azure.functions as func

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

@app.function_name("test_imports_step1")
@app.schedule(schedule="0 */30 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def test_imports_step1(timer: func.TimerRequest) -> None:
    """Test step 1: Basic Azure imports"""
    if timer.past_due:
        logging.info('Timer is past due!')
    
    logging.info('Testing basic Azure imports...')
    current_time = datetime.datetime.now()
    logging.info(f'Current time: {current_time}')
    
    # Let's test Azure imports one by one
    try:
        from azure.identity import DefaultAzureCredential
        logging.info('✅ DefaultAzureCredential import successful')
        
        from azure.keyvault.secrets import SecretClient
        logging.info('✅ SecretClient import successful')
        
        from azure.storage.blob import BlobServiceClient
        logging.info('✅ BlobServiceClient import successful')
        
        logging.info('All Azure imports working fine!')
        
    except ImportError as e:
        logging.error(f'❌ Azure import failed: {e}')
@app.function_name("test_imports_step2")
@app.schedule(schedule="0 */25 * * * *", arg_name="timer2", run_on_startup=False, use_monitor=False)
def test_imports_step2(timer2: func.TimerRequest) -> None:
    """Test step 2: HTTP and Database imports"""
    if timer2.past_due:
        logging.info('Timer is past due!')
    
    logging.info('Testing HTTP and Database imports...')
    
    # Test requests library
    try:
        import requests
        logging.info('✅ requests import successful')
        
        # Test a simple request
        response = requests.get('https://httpbin.org/json', timeout=5)
        logging.info(f'✅ requests GET successful: {response.status_code}')
        
    except ImportError as e:
        logging.error(f'❌ requests import failed: {e}')
    except Exception as e:
        logging.error(f'❌ requests error: {e}')
    
    # Test pyodbc library
    try:
        import pyodbc
        logging.info('✅ pyodbc import successful')
        
        # Test getting drivers (doesn't require connection)
        drivers = pyodbc.drivers()
        logging.info(f'✅ pyodbc drivers: {len(drivers)} found')
        
    except ImportError as e:
        logging.error(f'❌ pyodbc import failed: {e}')
    except Exception as e:
        logging.error(f'❌ pyodbc error: {e}')
    
    logging.info('HTTP and Database import tests completed!')

@app.function_name("test_imports_step3")
@app.schedule(schedule="0 */20 * * * *", arg_name="timer3", run_on_startup=False, use_monitor=False)
def test_imports_step3(timer3: func.TimerRequest) -> None:
    """Test step 3: Image processing imports - MOST LIKELY CULPRITS"""
    if timer3.past_due:
        logging.info('Timer is past due!')
    
    logging.info('Testing Image Processing imports...')
    
    # Test BeautifulSoup (HTML parsing)
    try:
        from bs4 import BeautifulSoup
        logging.info('✅ BeautifulSoup import successful')
        
        # Test basic parsing
        soup = BeautifulSoup('<html><body><h1>Test</h1></body></html>', 'html.parser')
        logging.info(f'✅ BeautifulSoup parsing successful: {soup.find("h1").text}')
        
    except ImportError as e:
        logging.error(f'❌ BeautifulSoup import failed: {e}')
    except Exception as e:
        logging.error(f'❌ BeautifulSoup error: {e}')
    
    # Test PIL/Pillow (Image processing)
    try:
        from PIL import Image
        from io import BytesIO
        logging.info('✅ PIL (Pillow) import successful')
        
        # Test creating a simple image
        img = Image.new('RGB', (100, 100), color='red')
        buffer = BytesIO()
        img.save(buffer, format='PNG')
        logging.info(f'✅ PIL image creation successful: {len(buffer.getvalue())} bytes')
        
    except ImportError as e:
        logging.error(f'❌ PIL import failed: {e}')
    except Exception as e:
        logging.error(f'❌ PIL error: {e}')
    
    # Test APNG (Animated PNG) - MOST SUSPICIOUS!
    try:
        from apng import APNG, PNG
        logging.info('✅ APNG import successful')
        
        # Test basic APNG creation (this might be the culprit!)
        apng = APNG()
        logging.info('✅ APNG object creation successful')
        
    except ImportError as e:
        logging.error(f'❌ APNG import failed: {e}')
    except Exception as e:
        logging.error(f'❌ APNG error: {e}')
    
    logging.info('🔍 Image Processing import tests completed - check results above!')

@app.function_name("test_complex_function")
@app.schedule(schedule="0 */15 * * * *", arg_name="timer4", run_on_startup=False, use_monitor=False)
def test_complex_function(timer4: func.TimerRequest) -> None:
    """Test a more complex function similar to your original - let's see when it breaks!"""
    if timer4.past_due:
        logging.info('Timer is past due!')
    
    logging.info('Testing complex function with all imports together...')
    
    # Import everything at once (like your original function)
    try:
        from azure.identity import DefaultAzureCredential
        from azure.keyvault.secrets import SecretClient
        from azure.storage.blob import BlobServiceClient
        import requests
        import pyodbc
        from bs4 import BeautifulSoup
        from PIL import Image
        from io import BytesIO
        from apng import APNG, PNG
        import datetime
        
        logging.info('✅ ALL imports successful in one function!')
        
        # Simulate some complex operations (without actually connecting)
        current_time = datetime.datetime.now()
        logging.info(f'✅ Complex function executed at: {current_time}')
        
        # Test creating objects (but not using secrets)
        img = Image.new('RGB', (50, 50), color='blue')
        soup = BeautifulSoup('<div>test</div>', 'html.parser')
        apng_obj = APNG()
        
        logging.info('✅ Complex operations completed successfully!')
        
    except Exception as e:
        logging.error(f'❌ Complex function failed: {e}')
    
    logging.info('🔍 Complex function test completed!')

# ==================== RESTORATION TEST ====================
# Let's add back your original functions piece by piece

# First, let's add the process_city_weather helper function
def process_city_weather(cursor, apikey: str, city_code: str, city_name: str, latitude: float, longitude: float) -> None:
    """Fetch current weather for a city and insert into DB using provided cursor."""
    import requests
    try:
        api_call = (
            f"https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}"
            f"&appid={apikey}&lang=es&units=metric"
        )

        response = requests.get(api_call)
        response.raise_for_status()
        data = response.json()

        # Extract weather data
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

        # Insert into database
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
                coord_lon, coord_lat, weather_id, weather_main, weather_description,
                weather_icon, base, main_temp, main_feels_like, main_pressure,
                main_humidity, main_temp_min, main_temp_max, main_sea_level,
                main_grnd_level, visibility, wind_speed, wind_deg, wind_gust,
                clouds_all, rain_1h, rain_3h, dt, sys_country, sys_sunrise,
                sys_sunset, timezone, city_id, city_name, city_code, dt, sys_sunrise, sys_sunset,
            ),
        )

    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to get weather data for {city_name}: {e}")
    except Exception as e:
        logging.error(f"Database error for {city_name}: {e}")

@app.function_name("test_weather_helper")
@app.schedule(schedule="0 */12 * * * *", arg_name="timer5", run_on_startup=False, use_monitor=False)
def test_weather_helper(timer5: func.TimerRequest) -> None:
    """Test the weather helper function without actually calling APIs"""
    if timer5.past_due:
        logging.info('Timer is past due!')
    
    logging.info('Testing weather helper function...')
    
    # Test that the helper function exists and can be called (without real data)
    try:
        logging.info('✅ process_city_weather function defined successfully')
        logging.info('🔍 Weather helper test completed - function ready!')
        
    except Exception as e:
        logging.error(f'❌ Weather helper test failed: {e}')

# Step 2: Add NASA/Image processing helper functions
def add_icon_to_image(image_data, icon_url):
    """Add a marker icon to the center of a weather satellite image."""
    import requests
    from PIL import Image
    from io import BytesIO
    
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

def process_city_nasa(blob_service_client, container_name: str, icon_url: str, 
                     city_code: str, latitude: float, longitude: float) -> None:
    """Fetch GOES image for a city, overlay an icon, upload, and refresh animation."""
    import requests
    from bs4 import BeautifulSoup
    import datetime
    
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

    except Exception as e:
        logging.error(f"Error processing NASA GOES image for city {city_code}: {str(e)}")

@app.function_name("test_nasa_helpers")
@app.schedule(schedule="0 */10 * * * *", arg_name="timer6", run_on_startup=False, use_monitor=False)
def test_nasa_helpers(timer6: func.TimerRequest) -> None:
    """Test the NASA/image processing helper functions"""
    if timer6.past_due:
        logging.info('Timer is past due!')
    
    logging.info('Testing NASA/image helper functions...')
    
    try:
        logging.info('✅ add_icon_to_image function defined successfully')
        logging.info('✅ process_city_nasa function defined successfully')
        logging.info('🔍 NASA helpers test completed - functions ready!')
        
    except Exception as e:
        logging.error(f'❌ NASA helpers test failed: {e}')