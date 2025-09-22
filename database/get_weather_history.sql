CREATE PROCEDURE weather.GetWeatherHistory
    @CityCode CHAR(3),
    @Days INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        Date_gt AS CollectionDate,
        Main_Humidity,
        isnull(str(Rain_1h,12,2),'0') as Rain_1h,
        isnull(str(Rain_3h,12,2),'0') as Rain_3h,
        Main_Temp,
        Main_Pressure
    FROM weather.WeatherData
    WHERE CityCode = @CityCode
      AND Date_gt >= DATEADD(day, -@Days, GETDATE())
    ORDER BY CollectionDate DESC;
END;
GO
