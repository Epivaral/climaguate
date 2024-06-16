CREATE PROCEDURE weather.GetCities
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CityCode, CityName 
    FROM weather.cities
    ORDER BY cityName;
END;
GO