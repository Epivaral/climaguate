
/*
Description: This stored procedure deletes weather data that is older than 5 days from the weather.WeatherData table.

Procedure: weather.Delete_weather
Parameters: None
Returns: None

Usage:
EXEC weather.Delete_weather;

Notes:
    - The procedure uses the DATEADD function to calculate the date 5 days before the current date.
    - The SET NOCOUNT ON statement is used to prevent the message indicating 
      the number of rows affected by a T-SQL statement from being returned.
*/

CREATE PROCEDURE weather.Delete_weather
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Delete from WeatherData
    DELETE FROM weather.WeatherData
    WHERE Date_gt < DATEADD(DAY, -5, GETDATE());

    -- Delete from WeatherForecast
    DELETE FROM weather.WeatherForecast
    WHERE ForecastDate < DATEADD(DAY, -5, GETDATE());

    -- Delete from AirQuality
    DELETE FROM weather.AirQuality
    WHERE Date_gt < DATEADD(DAY, -5, GETDATE());

    -- Delete from JobRunLock
    DELETE FROM JobRunLock
    WHERE RunTimeUtc < DATEADD(DAY, -5, GETDATE());


END;

GO
