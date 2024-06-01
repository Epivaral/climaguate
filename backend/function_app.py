import logging
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import requests
import pyodbc

app = func.FunctionApp()

@app.schedule(schedule="0 0 * * * *", arg_name="myTimer", run_on_startup=True,
              use_monitor=False) 
def Call_API_and_Store_in_SQL(myTimer: func.TimerRequest) -> None:
    if myTimer.past_due:
        logging.info('The timer is past due!')

    # Get the connection string from Azure Key Vault
    credential = DefaultAzureCredential()
    secret_client = SecretClient(vault_url="https://climaguatesecrets.vault.azure.net/", credential=credential)
    connection_string = secret_client.get_secret("connstr").value
    apikey = secret_client.get_secret("apikey").value

    # Call the API
    response = requests.get(f"https://api.openweathermap.org/data/2.5/weather?lat=14.6349&lon=-90.5069&appid={apikey}")
    data = response.json()

#sample response, used for reference
#{"coord":{"lon":-90.5069,"lat":14.6349},"weather":[{"id":500,"main":"Rain","description":"lluvia ligera","icon":"10d"}],"base":"stations","main":{"temp":300.11,"feels_like":300.53,"temp_min":295.71,"temp_max":300.11,"pressure":1019,"humidity":50},"visibility":10000,"wind":{"speed":7.2,"deg":20},"rain":{"1h":0.35},"clouds":{"all":40},"dt":1717112602,"sys":{"type":1,"id":7079,"country":"GT","sunrise":1717068722,"sunset":1717115257},"timezone":-21600,"id":3598132,"name":"Guatemala City","cod":200}

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
    visibility = data["visibility"]
    wind_speed = data["wind"]["speed"]
    wind_deg = data["wind"]["deg"]
    wind_gust = data["wind"].get("gust", None)  # Default to None if not present
    clouds_all = data["clouds"]["all"]
    rain_1h = data["rain"].get("1h", None)  # Default to None if not present
    rain_3h = data["rain"].get("3h", None)  # Default to None if not present
    dt = data["dt"]
    sys_country = data["sys"]["country"]
    sys_sunrise = data["sys"]["sunrise"]
    sys_sunset = data["sys"]["sunset"]
    timezone = data["timezone"]
    city_id = data["id"]
    city_name = data["name"]
    city_code = 'GUA' #just for testing at this point 

     # Connect to the SQL database
    conn = pyodbc.connect(connection_string)
    cursor = conn.cursor()

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

    # Commit and close
    conn.commit()
    cursor.close()
    conn.close()

    logging.info('Python timer trigger function executed.')
