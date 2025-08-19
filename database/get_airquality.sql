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
            CASE 
                WHEN AQI = 1 THEN 'Buena'
                WHEN AQI = 2 THEN 'Moderada'
                WHEN AQI = 3 THEN 'Regular'
                WHEN AQI = 4 THEN 'Mala'
                WHEN AQI = 5 THEN 'Muy Mala'
                ELSE 'Desconocida'
            END AS CategorySpanish,
            CASE 
                WHEN AQI = 1 THEN 'La calidad del aire es satisfactoria y la contaminación atmosférica presenta poco o ningún riesgo.'
                WHEN AQI = 2 THEN 'La calidad del aire es aceptable para la mayoría de las personas. Sin embargo, los grupos sensibles pueden experimentar síntomas menores.'
                WHEN AQI = 3 THEN 'Los miembros de grupos sensibles pueden experimentar problemas de salud. El público en general no se ve generalmente afectado.'
                WHEN AQI = 4 THEN 'Todos pueden comenzar a experimentar problemas de salud; los miembros de grupos sensibles pueden experimentar problemas de salud más serios.'
                WHEN AQI = 5 THEN 'Advertencias de salud de condiciones de emergencia. Es probable que toda la población se vea afectada.'
                ELSE 'Sin información disponible sobre los efectos en la salud.'
            END AS HealthDescription,
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
            CASE 
                WHEN aq.AQI = 1 THEN 'Buena'
                WHEN aq.AQI = 2 THEN 'Moderada'
                WHEN aq.AQI = 3 THEN 'Regular'
                WHEN aq.AQI = 4 THEN 'Mala'
                WHEN aq.AQI = 5 THEN 'Muy Mala'
                ELSE 'Desconocida'
            END AS CategorySpanish,
            CASE 
                WHEN aq.AQI = 1 THEN 'La calidad del aire es satisfactoria y la contaminación atmosférica presenta poco o ningún riesgo.'
                WHEN aq.AQI = 2 THEN 'La calidad del aire es aceptable para la mayoría de las personas. Sin embargo, los grupos sensibles pueden experimentar síntomas menores.'
                WHEN aq.AQI = 3 THEN 'Los miembros de grupos sensibles pueden experimentar problemas de salud. El público en general no se ve generalmente afectado.'
                WHEN aq.AQI = 4 THEN 'Todos pueden comenzar a experimentar problemas de salud; los miembros de grupos sensibles pueden experimentar problemas de salud más serios.'
                WHEN aq.AQI = 5 THEN 'Advertencias de salud de condiciones de emergencia. Es probable que toda la población se vea afectada.'
                ELSE 'Sin información disponible sobre los efectos en la salud.'
            END AS HealthDescription,
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
