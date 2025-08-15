"""
Weather processing helper functions for Climaguate
"""
import logging
import datetime
import requests
import pyodbc
from typing import Dict, Any, Optional


# Global session for HTTP request reuse
session = requests.Session()
session.timeout = (10, 30)  # (connection, read) timeouts


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


def process_forecast_for_city(cursor, apikey: str, city_code: str, latitude: float, longitude: float) -> int:
    """Process quarter-day forecast for a single city. Returns number of forecasts processed."""
    api_url = (
        f"https://atlas.microsoft.com/weather/forecast/quarterDay/json"
        f"?api-version=1.1&query={latitude},{longitude}&duration=1&subscription-key={apikey}&language=es-419"
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

        return city_forecast_count

    except requests.exceptions.RequestException as e:
        logging.error(f"API error for {city_code}: {e}")
        return 0
    except Exception as e:
        logging.error(f"Processing error for {city_code}: {e}")
        return 0
