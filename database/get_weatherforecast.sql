CREATE PROCEDURE weather.GetWeatherForecast
 @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT top (4) *
    FROM dbo.WeatherForecast
    WHERE CityCode = @CityCode
    ORDER BY  ForecastDate DESC,EffectiveDate;
END;
GO
