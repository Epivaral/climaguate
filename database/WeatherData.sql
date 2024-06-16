-- Create table
CREATE TABLE weather.WeatherData (
    Coord_Lon FLOAT NOT NULL, -- Longitude of the location
    Coord_Lat FLOAT NOT NULL, -- Latitude of the location
    Weather_Id INT NULL, -- Weather condition id
    Weather_Main NVARCHAR(50) NULL, -- Group of weather parameters (Rain, Snow, Clouds etc.)
    Weather_Description NVARCHAR(255) NULL, -- Weather condition within the group
    Weather_Icon NVARCHAR(50) NULL, -- Weather icon id
    Base NVARCHAR(50) NULL, -- Internal parameter
    Main_Temp FLOAT NULL, -- Temperature (Kelvin, Celsius, Fahrenheit)
    Main_Feels_Like FLOAT NULL, -- Temperature accounting for human perception
    Main_Pressure INT NULL, -- Atmospheric pressure on the sea level, hPa
    Main_Humidity INT NULL, -- Humidity, %
    Main_Temp_Min FLOAT NULL, -- Minimum temperature at the moment (Kelvin, Celsius, Fahrenheit)
    Main_Temp_Max FLOAT NULL, -- Maximum temperature at the moment (Kelvin, Celsius, Fahrenheit)
    Main_Sea_Level INT NULL, -- Atmospheric pressure on the sea level, hPa
    Main_Grnd_Level INT NULL, -- Atmospheric pressure on the ground level, hPa
    Visibility INT NULL, -- Visibility, meters
    Wind_Speed FLOAT NULL, -- Wind speed (meter/sec, miles/hour)
    Wind_Deg INT NULL, -- Wind direction, degrees
    Wind_Gust FLOAT NULL, -- Wind gust (meter/sec, miles/hour)
    Clouds_All INT NULL, -- Cloudiness, %
    Rain_1h FLOAT NULL, -- Rain volume for the last 1 hour, mm
    Rain_3h FLOAT NULL, -- Rain volume for the last 3 hours, mm (if available)
    Dt BIGINT NULL, -- Time of data calculation, unix, UTC
    Sys_Country CHAR(2) NULL, -- Country code (GB, JP etc.)
    Sys_Sunrise BIGINT NULL, -- Sunrise time, unix, UTC
    Sys_Sunset BIGINT NULL, -- Sunset time, unix, UTC
    Timezone INT NULL, -- Shift in seconds from UTC
    Id INT NOT NULL, -- City ID
    Name NVARCHAR(255) NOT NULL, -- City name
    CityCode CHAR(3) NOT NULL
);
GO


