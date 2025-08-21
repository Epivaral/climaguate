CREATE PROCEDURE weather.GetWeatherForecast 
 @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    -- Get the next 24 hours of hourly forecast data
    -- Ordered from soonest to latest (chronological order)
    SELECT TOP (24)
        CityCode,
        ForecastDate,
        EffectiveDate,
        Quarter,
        IconPhrase,
        Phrase,
        Temperature,
        RealFeelTemperature,
        DewPoint,
        RelativeHumidity,
        WindDirectionDegrees,
        WindDirectionDescription,
        WindSpeed,
        WindGustDirectionDegrees,
        WindGustDirectionDescription,
        WindGustSpeed,
        Visibility,
        CloudCover,
        HasPrecipitation,
        PrecipitationType,
        PrecipitationIntensity,
        PrecipitationProbability,
        ThunderstormProbability,
        TotalLiquid,
        Rain
    FROM weather.WeatherForecast
    WHERE CityCode = @CityCode
      AND EffectiveDate >= GETDATE()  -- Only future forecasts
    ORDER BY EffectiveDate ASC;  -- Chronological order (soonest first)
END;
GO
