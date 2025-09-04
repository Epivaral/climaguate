"""
=============================================================================
CLIMAGUATE - AZURE FUNCTIONS BACKEND
=============================================================================
This Azure Functions application provides the backend services for the 
Climaguate weather monitoring system for Guatemala.

Key Features:
- Automated weather data collection from OpenWeatherMap API
- Air quality monitoring with AQI calculations
- NASA GOES satellite image processing and animation generation
- Weather forecast data collection from Azure Maps API
- Azure Blob Storage integration for satellite imagery
- SQL Server database integration for data persistence

Functions:
1. run_city_batch: Timer-triggered function (every 15 minutes)
   - Collects current weather data for all cities
   - Retrieves air quality information
   - Downloads and processes NASA satellite images
   
2. get_quarterday_forecast: Timer-triggered function (every 12 hours)
   - Fetches extended weather forecasts
   - Stores forecast data for chart generation

Technical Stack:
- Azure Functions with Python runtime
- OpenWeatherMap API for weather and air quality data
- NASA GOES satellite imagery API
- Azure Maps API for forecasting
- Azure Blob Storage for image hosting
- SQL Server for data persistence
- PIL/Pillow for image processing
- APNG library for animation creation

Architecture:
- Timer-based triggers for automated data collection
- Managed identity for secure Azure service authentication
- Environment variables for configuration management
- Error handling with comprehensive logging
- Memory-optimized image processing for satellite animations
=============================================================================
"""

import logging
import datetime
import os
import json

import azure.functions as func

# Only import built-in and azure-functions modules at the top level
# Move problematic imports inside functions to avoid registration issues during deployment

# Initialize the Azure Functions app
app = func.FunctionApp()

# =============================================================================
# HELPER FUNCTIONS - DATA RETRIEVAL AND PROCESSING
# =============================================================================

def get_cities_from_api():
    """
    Fetch cities from Data API Builder endpoint using urllib.
    
    This function retrieves the list of cities configured in the system
    along with their coordinates for weather data collection.
    
    Returns:
        list: List of city dictionaries containing CityCode, CityName, 
              Latitude, and Longitude, or empty list on failure
              
    Error Handling:
        - HTTP errors from the API endpoint
        - Network timeouts and connection issues  
        - JSON parsing errors
    """
    from urllib.request import urlopen, Request
    from urllib.error import URLError, HTTPError
    import time

    api_url = "https://climaguate.com/data-api/rest/GetCities"
    request = Request(api_url)
    request.add_header('User-Agent', 'ClimaguateWeatherApp/1.0')

    max_retries = 3
    for attempt in range(1, max_retries + 1):
        try:
            with urlopen(request, timeout=10) as response:
                if response.status == 200:
                    data = json.loads(response.read().decode('utf-8'))
                    cities_list = data.get('value', [])
                    logging.info(f"✅ Loaded {len(cities_list)} cities from API with coordinates.")
                    return cities_list
                elif response.status == 500:
                    logging.error(f"❌ HTTP 500 from cities API (attempt {attempt})")
                    if attempt < max_retries:
                        logging.info(f"Waiting 30 seconds before retrying...")
                        time.sleep(30)
                    else:
                        logging.error("❌ Max retries reached. Aborting city fetch.")
                        return []
                else:
                    logging.error(f"❌ HTTP {response.status} from cities API (attempt {attempt})")
                    return []
        except HTTPError as e:
            if e.code == 500:
                logging.error(f"❌ HTTP 500 from cities API (attempt {attempt})")
                if attempt < max_retries:
                    logging.info(f"Waiting 30 seconds before retrying...")
                    time.sleep(30)
                else:
                    logging.error("❌ Max retries reached. Aborting city fetch.")
                    return []
            else:
                logging.error(f"❌ HTTPError fetching cities: {e}")
                return []
        except Exception as e:
            logging.error(f"❌ Error fetching cities: {e}")
            return []


def process_city_weather(cursor, apikey: str, city_code: str, city_name: str, latitude: float, longitude: float) -> None:
    """
    Fetch current weather data for a city from OpenWeatherMap API and insert into database.
    
    This function retrieves comprehensive weather information including temperature,
    humidity, wind, pressure, visibility, and precipitation data.
    
    Args:
        cursor: Database cursor for SQL operations
        apikey (str): OpenWeatherMap API key
        city_code (str): Unique city identifier (e.g., 'GUA')
        city_name (str): Human-readable city name  
        latitude (float): City latitude coordinate
        longitude (float): City longitude coordinate
        
    Database Operations:
        - Inserts complete weather record into weather.WeatherData table
        - Converts Unix timestamps to Central America timezone
        - Handles nullable fields gracefully
        
    API Integration:
        - Uses metric units and Spanish language
        - Includes current conditions and atmospheric data
        - Error handling for API failures and network issues
    """
    import requests  # Import inside function
    
    try:
        api_call = (
            f"https://api.openweathermap.org/data/2.5/weather?lat={latitude}&lon={longitude}"
            f"&appid={apikey}&lang=es&units=metric"
        )

        response = requests.get(api_call)
        response.raise_for_status()
        data = response.json()

        # Extract coordinate data
        coord_lon = data["coord"]["lon"]
        coord_lat = data["coord"]["lat"]
        
        # Weather condition information
        weather_id = data["weather"][0]["id"]
        weather_main = data["weather"][0]["main"]
        weather_description = data["weather"][0]["description"]
        weather_icon = data["weather"][0]["icon"]
        
        # Base station and main atmospheric data
        base = data.get("base")
        main_temp = data["main"]["temp"]
        main_feels_like = data["main"]["feels_like"]
        main_pressure = data["main"]["pressure"]
        main_humidity = data["main"]["humidity"]
        main_temp_min = data["main"]["temp_min"]
        main_temp_max = data["main"]["temp_max"]
        main_sea_level = data["main"].get("sea_level")
        main_grnd_level = data["main"].get("grnd_level")
        
        # Visibility and wind data
        visibility = data.get("visibility")
        wind_speed = data["wind"]["speed"]
        wind_deg = data["wind"]["deg"]
        wind_gust = data["wind"].get("gust")
        
        # Cloud coverage and precipitation
        clouds_all = data["clouds"]["all"]
        rain_1h = data.get("rain", {}).get("1h")
        rain_3h = data.get("rain", {}).get("3h")
        
        # Timestamp and system data
        dt = data["dt"]
        sys_country = data["sys"]["country"]
        sys_sunrise = data["sys"]["sunrise"]
        sys_sunset = data["sys"]["sunset"]
        timezone = data["timezone"]
        city_id = data["id"]

        # Insert weather data into database with timezone conversion
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


def process_city_air_quality(cursor, apikey: str, city_code: str, city_name: str, latitude: float, longitude: float) -> None:
    """
    Fetch air quality data for a city from OpenWeatherMap API and insert into database.
    
    This function retrieves comprehensive air pollution data including AQI levels
    and individual pollutant concentrations for health monitoring.
    
    Args:
        cursor: Database cursor for SQL operations
        apikey (str): OpenWeatherMap API key
        city_code (str): Unique city identifier
        city_name (str): Human-readable city name
        latitude (float): City latitude coordinate
        longitude (float): City longitude coordinate
        
    Air Quality Data:
        - Overall AQI (Air Quality Index) on 1-5 scale
        - Individual pollutant concentrations (μg/m³):
          * CO (Carbon Monoxide)
          * NO (Nitrogen Monoxide) 
          * NO2 (Nitrogen Dioxide)
          * O3 (Ozone)
          * SO2 (Sulfur Dioxide)
          * PM2.5 (Fine Particulate Matter)
          * PM10 (Coarse Particulate Matter)
          * NH3 (Ammonia)
          
    Database Operations:
        - Inserts complete air quality record into weather.AirQuality table
        - Maps numeric AQI to descriptive categories
        - Handles missing pollutant data with default values
    """
    import requests  # Import inside function
    
    try:
        api_call = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={latitude}&lon={longitude}&appid={apikey}"

        response = requests.get(api_call)
        response.raise_for_status()
        data = response.json()

        # Extract air quality data from API response
        air_data = data["list"][0]  # Current air quality data
        aqi = air_data["main"]["aqi"]  # Air Quality Index (1-5)
        components = air_data["components"]
        
        # Get timestamp for data collection
        dt = air_data["dt"]
        
        # Map numeric AQI to descriptive categories for database storage
        aqi_categories = {
            1: "Good",
            2: "Fair", 
            3: "Moderate",
            4: "Poor",
            5: "Very Poor"
        }
        category = aqi_categories.get(aqi, "Unknown")

        # Insert air quality data into database
        insert_query = '''
            INSERT INTO weather.AirQuality (
                CityCode, CityName, Latitude, Longitude, 
                AQI, Category, 
                CO, NO, NO2, O3, SO2, PM2_5, PM10, NH3,
                Timestamp, Date_gt
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                DATEADD(second, ?, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time')
        '''

        cursor.execute(
            insert_query,
            (
                city_code,
                city_name,
                latitude,
                longitude,
                aqi,
                category,
                components.get("co", 0),        # Carbon monoxide (μg/m³)
                components.get("no", 0),        # Nitrogen monoxide (μg/m³)
                components.get("no2", 0),       # Nitrogen dioxide (μg/m³)
                components.get("o3", 0),        # Ozone (μg/m³)
                components.get("so2", 0),       # Sulphur dioxide (μg/m³)
                components.get("pm2_5", 0),     # PM2.5 (μg/m³)
                components.get("pm10", 0),      # PM10 (μg/m³)
                components.get("nh3", 0),       # Ammonia (μg/m³)
                dt,
                dt
            ),
        )
        
        logging.info(f"Air quality data inserted for {city_name} - AQI: {aqi} ({category})")

    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to get air quality data for {city_name}: {e}")
    except Exception as e:
        logging.error(f"Error processing air quality data for {city_name}: {e}")


def process_city_nasa(
    blob_service_client,
    container_name: str,
    icon_url: str,
    city_code: str,
    latitude: float,
    longitude: float,
) -> None:
    """
    Fetch NASA GOES satellite image for a city, overlay location icon, and generate animation.
    
    This function downloads infrared satellite imagery from NASA's GOES satellite system,
    processes the image by cropping and adding a location marker, uploads to Azure Blob Storage,
    and triggers animation generation from recent images.
    
    Args:
        blob_service_client: Azure Blob Storage service client
        container_name (str): Blob storage container name
        icon_url (str): URL to location marker icon
        city_code (str): Unique city identifier for file organization
        latitude (float): City latitude for satellite positioning
        longitude (float): City longitude for satellite positioning
        
    Image Processing:
        - Downloads infrared imagery from NASA GOES satellite
        - Crops to 400x400 pixel square centered on coordinates
        - Overlays location marker icon for geographic reference
        - Saves as JPEG format for web optimization
        
    Storage Operations:
        - Uploads processed image to Azure Blob Storage
        - Organizes files by city code in folder structure
        - Triggers animation generation from recent images
        - Provides timestamped filename for tracking
        
    Error Handling:
        - Network failures during image download
        - Image processing errors
        - Blob storage upload failures
        - HTML parsing issues from NASA website
    """
    import requests  # Import inside function
    from bs4 import BeautifulSoup
    
    try:
        # Generate timestamped filename for image organization
        date_img = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        blob_name = f"{city_code}/{date_img}.jpg"

        # Construct NASA GOES satellite image URL with specific parameters
        image_page_url = (
            "https://weather.ndc.nasa.gov/cgi-bin/get-abi?"
            f"satellite=GOESEastfullDiskband13&lat={latitude}&lon={longitude}&quality=100&palette=ir2.pal&colorbar=0&mapcolor=white"
        )

        response = requests.get(image_page_url)
        if response.status_code == 200:
            html_content = response.text

            # Parse HTML to extract the actual satellite image URL
            soup = BeautifulSoup(html_content, "html.parser")
            img_tag = soup.find("img")
            if img_tag and "src" in img_tag.attrs:
                img_url = "https://weather.ndc.nasa.gov" + img_tag["src"]

                # Download the satellite image
                img_response = requests.get(img_url)
                if img_response.status_code == 200:
                    from PIL import Image
                    from io import BytesIO
                    
                    # Convert bytes to PIL Image for processing
                    image_data = Image.open(BytesIO(img_response.content))
                    main_width, main_height = image_data.size

                    # Crop the image to a square from the center, approximately 400x400 pixels
                    # This focuses the view on the specific geographic area of interest
                    crop_size = 400
                    left = (main_width - crop_size) // 2
                    top = (main_height - crop_size) // 2
                    right = left + crop_size
                    bottom = top + crop_size
                    
                    # Ensure crop bounds are within image dimensions to prevent errors
                    left = max(0, left)
                    top = max(0, top)
                    right = min(main_width, right)
                    bottom = min(main_height, bottom)
                    
                    # Perform the crop operation
                    image_data = image_data.crop((left, top, right, bottom))

                    # Add location marker icon to the processed image
                    modified_image_data = add_icon_to_image(image_data, icon_url)

                    # Upload processed image to Azure Blob Storage
                    blob_client = blob_service_client.get_blob_client(
                        container=container_name, blob=blob_name
                    )
                    blob_client.upload_blob(
                        modified_image_data, blob_type="BlockBlob", overwrite=True
                    )
                    logging.info(f"Image uploaded to {container_name}/{blob_name}")

                    # Generate updated animation from recent images
                    generate_animation_for_city(
                        city_code, blob_service_client, container_name
                    )

    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to get NASA image for {city_code}: {e}")


# =============================================================================
# MAIN AZURE FUNCTIONS - TIMER TRIGGERED SERVICES
# =============================================================================

@app.schedule(schedule="0 */20 * * * *", arg_name="timer", run_on_startup=False, use_monitor=False)
def run_city_batch(timer: func.TimerRequest) -> None:
    """
    Main weather data collection function - Executes every 20 minutes.

    This timer-triggered function orchestrates the complete weather data collection
    process for all configured cities in the Climaguate system.

    Schedule: Every 20 minutes (CRON: "0 */20 * * * *")

    Process Flow:
    1. Retrieves list of cities from Data API
    2. Connects to SQL database using environment variables
    3. Initializes Azure Blob Storage with managed identity
    4. For each city:
       - Collects current weather data from OpenWeatherMap
       - Retrieves air quality information and AQI levels
       - Downloads and processes NASA GOES satellite imagery
       - Generates animated satellite imagery timeline
    5. Commits all database transactions atomically
    
    Error Handling:
    - Individual city failures don't stop processing of other cities
    - Database connection errors are logged and handled gracefully
    - API failures are retried automatically by the timer schedule
    - Blob storage operations have built-in retry mechanisms
    
    Authentication:
    - Uses environment variables for API keys and connection strings
    - Managed identity for Azure Blob Storage access
    - No hardcoded secrets or credentials
    
    Performance Optimization:
    - Single database connection for all operations
    - Batch commits for improved throughput
    - Memory-efficient image processing
    - Parallel-safe error isolation per city
    """
    # Import problematic modules inside the function to avoid registration issues
    import pyodbc
    from azure.storage.blob import BlobServiceClient
    
    if timer.past_due:
        logging.info('The timer is past due!')

    conn = None
    cursor = None
    try:
        logging.info('Starting the process to retrieve configuration from environment variables.')

        # Retrieve configuration from environment variables (Azure Functions auto-maps Key Vault to env vars)
        connection_string = os.environ.get("connstr")
        apikey = os.environ.get("apikey")
        
        if not connection_string or not apikey:
            raise ValueError("Missing required environment variables: connstr and/or apikey")

        # Establish SQL database connection
        logging.info('Connecting to the SQL database.')
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        logging.info('Successfully connected to the SQL database.')

        # Initialize Azure Blob Storage client with managed identity
        storage_account_name = "imagefilesclimaguate"
        container_name = "mapimages"
        icon_url = "https://climaguate.com/images/icons/marker.png"
        
        # Use managed identity for secure authentication to blob storage
        from azure.identity import DefaultAzureCredential
        credential = DefaultAzureCredential()
        blob_service_client = BlobServiceClient(
            account_url=f"https://{storage_account_name}.blob.core.windows.net",
            credential=credential
        )

        # Fetch cities from Data API instead of direct database query for flexibility
        logging.info('Fetching city details from Data API.')
        cities_data = get_cities_from_api()
        
        if not cities_data:
            logging.error('❌ Failed to fetch cities from API - aborting batch processing')
            return
            
        logging.info(f'Successfully fetched {len(cities_data)} cities from API.')

        # Process each city individually with error isolation
        for city in cities_data:
            city_code = city.get('CityCode')
            city_name = city.get('CityName')
            latitude = city.get('Latitude')
            longitude = city.get('Longitude')
            
            # Skip cities with missing required data to prevent processing errors
            if not city_code or not city_name or latitude is None or longitude is None:
                logging.warning(f"⚠️ Skipping city with missing data: {city}")
                continue

            logging.info(f"Processing {city_code} - {city_name} ({latitude}, {longitude})")

            # Process weather data collection with individual error handling
            try:
                process_city_weather(cursor, apikey, city_code, city_name, latitude, longitude)
            except Exception as e:
                logging.error(f"Weather processing failed for {city_code}: {str(e)}")

            # Process air quality data collection with individual error handling
            try:
                process_city_air_quality(cursor, apikey, city_code, city_name, latitude, longitude)
            except Exception as e:
                logging.error(f"Air quality processing failed for {city_code}: {str(e)}")

            # Process NASA satellite imagery with individual error handling
            try:
                process_city_nasa(blob_service_client, container_name, icon_url, city_code, latitude, longitude)
            except Exception as e:
                logging.error(f"NASA processing failed for {city_code}: {str(e)}")

        # Commit all database writes atomically after successful processing
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


# =============================================================================
# IMAGE PROCESSING HELPER FUNCTIONS
# =============================================================================

def add_icon_to_image(main_image, icon_url):
    """
    Add a location marker icon overlay to a satellite image.
    
    This function downloads a location marker icon and overlays it on the center
    of a satellite image to provide geographic reference for users.
    
    Args:
        main_image: PIL Image object (satellite image)
        icon_url (str): URL to the location marker icon
        
    Returns:
        bytes: JPEG-encoded image data with icon overlay
        
    Processing Details:
        - Downloads icon from provided URL
        - Calculates center position for icon placement
        - Uses PNG transparency for proper overlay
        - Returns original image if icon processing fails
        - Memory-efficient conversion to bytes format
        
    Error Handling:
        - Network failures during icon download
        - Image format incompatibilities
        - Memory allocation issues
        - Graceful fallback to original image
    """
    import requests  # Import inside function
    from PIL import Image
    from io import BytesIO
    
    try:
        # main_image is already a PIL Image object from previous processing
        
        # Download the location marker icon
        icon_response = requests.get(icon_url)
        if icon_response.status_code == 200:
            icon_image = Image.open(BytesIO(icon_response.content))
            
            # Calculate the position to center the icon on the main image
            # Offset slightly above center for better visual positioning
            main_width, main_height = main_image.size
            icon_position = ((main_width - 19) // 2, (main_height // 2)-26)
            
            # Paste the icon onto the main image using transparency
            main_image.paste(icon_image, icon_position, icon_image)
            
            # Convert processed image back to bytes for storage
            output = BytesIO()
            main_image.save(output, format='JPEG')
            return output.getvalue()
        else:
            # Return original image as bytes if icon download failed
            output = BytesIO()
            main_image.save(output, format='JPEG')
            return output.getvalue()
    except Exception as e:
        logging.error(f"Error adding icon to image: {str(e)}")
        # Return original image as bytes if any error occurs
        output = BytesIO()
        main_image.save(output, format='JPEG')
        return output.getvalue()



def generate_animation_for_city(city_code: str, blob_service_client, container_name: str) -> bool:
    """
    Generate animated PNG from recent satellite images for a city with memory optimization.
    
    This function creates an animated timeline showing cloud movement and weather patterns
    by combining the most recent satellite images into a smooth animation.
    
    Args:
        city_code (str): Unique city identifier for image organization
        blob_service_client: Azure Blob Storage service client
        container_name (str): Blob storage container name
        
    Returns:
        bool: True if animation was successfully created, False otherwise
        
    Animation Process:
        - Retrieves up to 10 most recent satellite images for the city
        - Sorts images by timestamp in chronological order
        - Resizes images for web optimization (max 600x600)
        - Creates APNG animation with 500ms frame delays
        - Uploads final animation to replace previous version
        
    Memory Optimization:
        - Processes images one at a time to minimize memory usage
        - Uses thumbnail resizing for efficient scaling
        - Streams image data directly to avoid large memory allocations
        - Garbage collection friendly image handling
        
    Error Handling:
        - Graceful handling of corrupted or missing images
        - Continues processing if individual frames fail
        - Validates minimum frame count for meaningful animation
        - Comprehensive logging for debugging
    """
    from PIL import Image
    from io import BytesIO
    from apng import APNG, PNG
    
    try:
        # List all satellite images for this city, sorted by modification date
        blobs = []
        for blob in blob_service_client.get_container_client(container_name).list_blobs(name_starts_with=f"{city_code}/"):
            if blob.name.endswith('.jpg'):
                blobs.append(blob)
        
        # Sort by last modified descending (newest first) for chronological processing
        blobs.sort(key=lambda x: x.last_modified, reverse=True)
        
        if len(blobs) < 2:
            logging.info(f"Not enough images for animation for city {city_code} (found {len(blobs)})")
            return False

        # Use up to the latest 10 images for optimal animation performance
        blobs_to_use = blobs[:10]

        # Reverse the order to show chronological progression (oldest to newest)
        blobs_to_use.reverse()

        # Create APNG animation from processed images
        files = []
        for i, blob in enumerate(blobs_to_use):
            try:
                # Download satellite image blob
                blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob.name)
                blob_data = blob_client.download_blob().readall()
                
                # Load as PIL Image and optimize for web display
                img = Image.open(BytesIO(blob_data))
                
                # Resize to reasonable size for web performance (optional optimization)
                if img.size[0] > 600 or img.size[1] > 600:
                    img.thumbnail((600, 600), Image.Resampling.LANCZOS)
                
                # Convert to PNG format for animation compatibility
                png_bytes = BytesIO()
                img.save(png_bytes, format='PNG')
                png_bytes.seek(0)
                
                # Add frame to animation with timing control (500ms per frame)
                files.append(PNG.from_bytes(png_bytes.getvalue()))
                
            except Exception as e:
                logging.warning(f"Failed to process blob {blob.name} for animation: {e}")
                continue
        
        if len(files) < 2:
            logging.warning(f"Not enough valid images processed for city {city_code} animation.")
            return False
            
        # Create smooth animation with appropriate frame timing
        apng = APNG()
        for png in files:
            apng.append(png, delay=500)  # 500ms delay between frames for smooth motion
        
        # Generate animation data in memory
        animation_data = BytesIO()
        apng.save(animation_data)
        animation_bytes = animation_data.getvalue()
        
        if len(animation_bytes) == 0:
            logging.error(f"Generated animation is empty for city {city_code}")
            return False
        
        # Upload the completed animation to replace previous version
        animation_blob_name = f"{city_code}/animation.png"
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=animation_blob_name)
        blob_client.upload_blob(animation_bytes, blob_type="BlockBlob", overwrite=True)
        logging.info(f"Animation uploaded to {container_name}/{animation_blob_name}")
        
        return True
        
    except Exception as e:
        logging.error(f"Error generating animation for city {city_code}: {str(e)}")
        return False


# =============================================================================
# WEATHER FORECAST COLLECTION FUNCTION
# =============================================================================#

@app.schedule(schedule="0 0 */12 * * *", arg_name="hourlyTimer", run_on_startup=False, use_monitor=False)
def get_hourly_forecast(hourlyTimer: func.TimerRequest) -> None:
    """
    Hourly weather forecast collection function - Executes every 12 hours.

    This timer-triggered function collects detailed hourly weather forecast data
    for chart generation and extended weather planning.

    Schedule: Every 12 hours (CRON: "0 0 */12 * * *")

    Process Flow:
    1. Retrieves list of cities from Data API
    2. Connects to SQL database for forecast storage
    3. For each city:
       - Calls Azure Maps Weather API for hourly forecasts (12 hours ahead)
       - Extracts comprehensive forecast data (temperature, humidity, wind, precipitation)
       - Stores forecast records in WeatherForecast table
    4. Commits all forecast data atomically
    
    Forecast Data Collected:
    - Hourly temperature readings (single value per hour)
    - Real-feel temperature calculations
    - Wind speed and direction with gust information
    - Precipitation probability and intensity
    - Cloud coverage and visibility
    - Thunderstorm probability
    - Detailed weather phrases in Spanish
    
    API Integration:
    - Uses Azure Maps Hourly Weather API with Spanish localization
    - 12-hour duration for detailed short-term forecasting
    - Geographic coordinate-based requests
    - Comprehensive error handling for API failures
    
    Database Operations:
    - Stores forecasts in WeatherForecast table
    - Quarter field set to NULL since hourly doesn't use quarters
    - Uses dateTime instead of effectiveDate for hourly precision
    - Timezone-aware timestamp handling
    - Nested JSON data extraction and flattening
    - Batch commits for performance optimization
    """
    # Import problematic modules inside the function
    import pyodbc
    import requests  # Add requests import
    
    if hourlyTimer.past_due:
        logging.info('The timer is past due!')

    conn = None
    try:
        logging.info('Starting forecast process with environment variables.')
        
        # Retrieve configuration from environment variables
        connection_string = os.environ.get("connstr")
        apikey = os.environ.get("azuremapskey")  # Different API key for Azure Maps forecasts
        
        if not connection_string or not apikey:
            raise ValueError("Missing required environment variables: connstr and/or azuremapskey")

        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()

        # Fetch cities from Data API for consistent city management
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
            
            # Skip cities with missing required coordinate data
            if not city_code or not city_name or lat is None or lon is None:
                logging.warning(f"⚠️ Skipping forecast for city with missing data: {city}")
                continue

            # Construct Azure Maps Weather API URL with Spanish localization (Hourly Forecast)
            api_url = (
                f"https://atlas.microsoft.com/weather/forecast/hourly/json"
                f"?api-version=1.1&query={lat},{lon}&duration=12&subscription-key={apikey}&language=es-419"
            )

            try:
                response = requests.get(api_url)
                response.raise_for_status()
                forecast_data = response.json()

                forecasts = forecast_data.get("forecasts", [])

                for forecast in forecasts:
                    # Insert comprehensive hourly forecast data into database
                    insert_query = '''
                    INSERT INTO weather.WeatherForecast (
                        CityCode, ForecastDate, EffectiveDate, Quarter,
                        IconPhrase, Phrase,
                        Temperature, RealFeelTemperature,
                        DewPoint, RelativeHumidity,
                        WindDirectionDegrees, WindDirectionDescription, WindSpeed,
                        WindGustSpeed,
                        Visibility, CloudCover,
                        HasPrecipitation, PrecipitationType, PrecipitationIntensity,
                        PrecipitationProbability,
                        TotalLiquid, Rain
                    ) VALUES (
                        ?, 
                        SYSDATETIMEOFFSET() AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time',  
                        ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                    )
                    '''
                    # Execute hourly forecast data insertion with simplified parameter mapping
                    cursor.execute(insert_query, (
                        city_code,
                        forecast.get("date"),  # Fixed: API returns "date" not "dateTime"
                        None,  # Quarter field set to None since hourly doesn't have quarters
                        forecast.get("iconPhrase"),
                        forecast.get("iconPhrase"),  # Fixed: API doesn't have "shortPhrase", using iconPhrase
                        forecast.get("temperature", {}).get("value"),  # Single temperature value from hourly API
                        forecast.get("realFeelTemperature", {}).get("value"),  # Single real feel value from hourly API
                        forecast.get("dewPoint", {}).get("value"),
                        forecast.get("relativeHumidity"),
                        forecast.get("wind", {}).get("direction", {}).get("degrees"),
                        forecast.get("wind", {}).get("direction", {}).get("localizedDescription"),
                        forecast.get("wind", {}).get("speed", {}).get("value"),
                        forecast.get("windGust", {}).get("speed", {}).get("value"),
                        forecast.get("visibility", {}).get("value"),
                        forecast.get("cloudCover"),
                        forecast.get("hasPrecipitation"),
                        forecast.get("precipitationType"),
                        forecast.get("precipitationIntensity"),
                        forecast.get("precipitationProbability"),
                        forecast.get("totalLiquid", {}).get("value"),
                        forecast.get("rain", {}).get("value")
                    ))

            except requests.exceptions.RequestException as e:
                logging.error(f"API error for {city_code}: {e}")

        # Commit all forecast data atomically
        conn.commit()

        # Optional: Mark forecast collection as completed for monitoring
        # cursor.execute("UPDATE JobRunLock SET Status = ? WHERE RunTimeUtc = ?", ('Completed', run_time))
        # conn.commit()

    except Exception as e:
        logging.error(f"An error occurred in get_hourly_forecast: {str(e)}")
    finally:
        if conn is not None:
            conn.close()
