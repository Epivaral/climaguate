CREATE PROCEDURE [weather].[GetLatestAirQuality]
    @CityCode NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @CityCode IS NOT NULL
    BEGIN
        -- Get latest air quality for specific city
        SELECT TOP 1
            CityCode,
            CityName,
            Latitude,
            Longitude,
            AQI,
            Category,
            CO,
            NO,
            NO2,
            O3,
            SO2,
            PM2_5,
            PM10,
            NH3,
            Date_gt,
            CreatedAt
        FROM [weather].[AirQuality]
        WHERE CityCode = @CityCode
        ORDER BY Date_gt DESC;
    END
    ELSE
    BEGIN
        -- Get latest air quality for all cities
        WITH LatestPerCity AS (
            SELECT 
                CityCode,
                MAX(Date_gt) AS LatestDate
            FROM [weather].[AirQuality]
            GROUP BY CityCode
        )
        SELECT 
            aq.CityCode,
            aq.CityName,
            aq.Latitude,
            aq.Longitude,
            aq.AQI,
            aq.Category,
            aq.CO,
            aq.NO,
            aq.NO2,
            aq.O3,
            aq.SO2,
            aq.PM2_5,
            aq.PM10,
            aq.NH3,
            aq.Date_gt,
            aq.CreatedAt
        FROM [weather].[AirQuality] aq
        INNER JOIN LatestPerCity lpc ON aq.CityCode = lpc.CityCode 
                                    AND aq.Date_gt = lpc.LatestDate
        ORDER BY aq.CityName;
    END
END
