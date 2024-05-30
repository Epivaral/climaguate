-- Create table
CREATE TABLE weather.WeatherData (
    Coord_Lon FLOAT, -- Longitude of the location
    Coord_Lat FLOAT, -- Latitude of the location
    Weather_Id INT, -- Weather condition id
    Weather_Main NVARCHAR(50), -- Group of weather parameters (Rain, Snow, Clouds etc.)
    Weather_Description NVARCHAR(255), -- Weather condition within the group
    Weather_Icon NVARCHAR(50), -- Weather icon id
    Base NVARCHAR(50), -- Internal parameter
    Main_Temp FLOAT, -- Temperature (Kelvin, Celsius, Fahrenheit)
    Main_Feels_Like FLOAT, -- Temperature accounting for human perception
    Main_Pressure INT, -- Atmospheric pressure on the sea level, hPa
    Main_Humidity INT, -- Humidity, %
    Main_Temp_Min FLOAT, -- Minimum temperature at the moment (Kelvin, Celsius, Fahrenheit)
    Main_Temp_Max FLOAT, -- Maximum temperature at the moment (Kelvin, Celsius, Fahrenheit)
    Main_Sea_Level INT, -- Atmospheric pressure on the sea level, hPa
    Main_Grnd_Level INT, -- Atmospheric pressure on the ground level, hPa
    Visibility INT, -- Visibility, meters
    Wind_Speed FLOAT, -- Wind speed (meter/sec, miles/hour)
    Wind_Deg INT, -- Wind direction, degrees
    Wind_Gust FLOAT, -- Wind gust (meter/sec, miles/hour)
    Clouds_All INT, -- Cloudiness, %
    Rain_1h FLOAT, -- Rain volume for the last 1 hour, mm
    Rain_3h FLOAT, -- Rain volume for the last 3 hours, mm (if available)
    Dt BIGINT, -- Time of data calculation, unix, UTC
    Sys_Country CHAR(2), -- Country code (GB, JP etc.)
    Sys_Sunrise BIGINT, -- Sunrise time, unix, UTC
    Sys_Sunset BIGINT, -- Sunset time, unix, UTC
    Timezone INT, -- Shift in seconds from UTC
    Id INT, -- City ID
    Name NVARCHAR(255), -- City name
    CityCode CHAR(3) NULL,
);
GO
