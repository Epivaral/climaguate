CREATE PROCEDURE weather.GetWeatherHistory
    @CityCode CHAR(3),
    @Days INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        -- Group by hour, create a datetime for the start of each hour
        DATEADD(hour, DATEDIFF(hour, 0, Date_gt), 0) AS CollectionDate,
        
        -- Average all the measures for each hour
        AVG(CAST(Main_Humidity AS FLOAT)) AS Main_Humidity,
        isnull(str(AVG(ISNULL(Rain_1h, 0)),12,2),'0') as Rain_1h,
        isnull(str(AVG(ISNULL(Rain_3h, 0)),12,2),'0') as Rain_3h,
        AVG(Main_Temp) AS Main_Temp,
        AVG(CAST(Main_Pressure AS FLOAT)) AS Main_Pressure
    FROM weather.WeatherData
    WHERE CityCode = @CityCode
      AND Date_gt >= DATEADD(day, -@Days, GETDATE())
    GROUP BY 
        -- Group by year, month, day, and hour
        DATEADD(hour, DATEDIFF(hour, 0, Date_gt), 0)
    ORDER BY CollectionDate DESC;
END;
GO
