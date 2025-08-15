CREATE PROCEDURE weather.GetCities
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CityCode, CityName, Latitude, Longitude 
FROM weather.cities
ORDER BY cityName;
END;
GO