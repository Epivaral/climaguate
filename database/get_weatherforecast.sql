CREATE PROCEDURE weather.GetWeatherForecast
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM weather.WeatherForecast
    ORDER BY CityCode, ForecastDate;
END;
GO
