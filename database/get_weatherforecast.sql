CREATE PROCEDURE weather.GetWeatherForecast 
 @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    DROP TABLE IF EXISTS #ForecastMeasures;

    SELECT top (4)
        *
    into #ForecastMeasures
    FROM dbo.WeatherForecast
    WHERE CityCode = @CityCode
    ORDER BY ForecastDate DESC;

    SELECT *
    FROM #ForecastMeasures
    ORDER BY EffectiveDate;
END;
GO
