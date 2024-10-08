
/*
Description: This stored procedure deletes weather data that is older than 7 days from the weather.WeatherData table.

Procedure: weather.Delete_weather
Parameters: None
Returns: None

Usage:
EXEC weather.Delete_weather;

Notes:
    - The procedure uses the DATEADD function to calculate the date 7 days before the current date.
    - The SET NOCOUNT ON statement is used to prevent the message indicating 
      the number of rows affected by a T-SQL statement from being returned.
*/

CREATE PROCEDURE weather.Delete_weather
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM weather.WeatherData
    WHERE Date_gt < DATEADD(DAY, -7, GETDATE());
END;
GO