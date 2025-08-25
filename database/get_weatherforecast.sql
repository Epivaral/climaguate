CREATE PROCEDURE weather.GetWeatherForecast 
 @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    -- Get the next 24 hours of hourly forecast data
    -- Only the most recent forecast for each effective date
    -- Ordered from soonest to latest (chronological order)
    WITH RankedForecasts AS (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY CityCode, EffectiveDate 
                   ORDER BY ForecastDate DESC
               ) as rn
        FROM weather.WeatherForecast
        WHERE CityCode = @CityCode
          AND EffectiveDate >= GETDATE()  -- Only future forecasts
    )
    SELECT TOP (24)
        CityCode,
        ForecastDate,
        EffectiveDate,
        IconPhrase,
        Phrase,
        Temperature,
        RealFeelTemperature,
        HasPrecipitation,
        PrecipitationType,
        PrecipitationIntensity,
        PrecipitationProbability,
        TotalLiquid,
        Rain
    FROM RankedForecasts
    WHERE rn = 1  -- Only the most recent forecast for each effective date
    ORDER BY EffectiveDate ASC;  -- Chronological order (soonest first)
END;
GO
