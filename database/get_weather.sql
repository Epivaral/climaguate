CREATE PROCEDURE weather.GetWeather
    @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    -- Fetch data filtered by city code
    SELECT DISTINCT TOP (5)
        [Name],
        Weather_Description,
        Weather_Icon,
        Main_Temp,
        Main_Feels_Like,
        Main_Pressure,
        Main_Humidity,
        Main_Temp_Min,
        Main_Temp_Max,
        Main_Sea_Level,
        Main_Grnd_Level,
        Visibility,
        Wind_Speed,
        Wind_Deg,
        Wind_Gust,
        Clouds_All,
        ISNULL(STR(Rain_1h, 12, 2), 'n/a') AS Rain_1h,
        ISNULL(STR(Rain_3h, 12, 2), 'n/a') AS Rain_3h,
        DATEADD(SECOND, Dt, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time' AS CollectionDate, -- Convert Dt to Guatemala date
        DATEADD(SECOND, Sys_Sunrise, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time' AS SunriseDate,
        DATEADD(SECOND, Sys_Sunset, '1970-01-01') AT TIME ZONE 'UTC' AT TIME ZONE 'Central America Standard Time' AS SunsetDate
    FROM weather.WeatherData
    WHERE CityCode = @CityCode
    ORDER BY CollectionDate DESC;

END;
GO