-- Test the GetCropsByCity procedure with simplified logic
CREATE OR ALTER PROCEDURE agriculture.GetCropsByCity_Test
    @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get latest weather data for the city (simplified)
    DECLARE @CurrentTemp FLOAT = NULL;
    DECLARE @CurrentHumidity INT = NULL;
    
    SELECT TOP 1 
        @CurrentTemp = Main_Temp,
        @CurrentHumidity = Main_Humidity
    FROM weather.WeatherData 
    WHERE CityCode = @CityCode
    ORDER BY Date_gt DESC;
    
    SELECT 
        -- City information
        c.CityCode,
        c.CityName,
        c.ElevationMeters,
        c.SoilType,
        c.ClimateZone,
        
        -- Crop information
        cr.CropCode,
        cr.CropNameSpanish,
        cr.CropNameEnglish,
        cr.OptimalTempMin,
        cr.OptimalTempMax,
        cr.OptimalHumidityMin,
        cr.OptimalHumidityMax,
        cr.StressTempMin,
        cr.StressTempMax,
        cr.PlantingMonths,
        cr.HarvestMonths,
        cr.WaterRequirement,
        cr.WaterRequirementMmPerWeek,
        cr.GrowthCycleDays,
        
        -- Regional suitability (static from table)
        cc.SuitabilityScore AS StaticSuitabilityScore,
        cc.IsPrimary,
        cc.LocalTempAdjustment,
        cc.LocalHumidityAdjustment,
        cc.Notes,
        
        -- Current weather context
        @CurrentTemp AS CurrentTemp,
        @CurrentHumidity AS CurrentHumidity,
        
        -- Dynamic suitability calculation
        CASE 
            WHEN @CurrentTemp IS NOT NULL AND @CurrentHumidity IS NOT NULL THEN
                agriculture.CalculateSuitabilityScore(
                    @CurrentTemp, 
                    @CurrentHumidity, 
                    cr.OptimalTempMin, 
                    cr.OptimalTempMax, 
                    cr.OptimalHumidityMin, 
                    cr.OptimalHumidityMax, 
                    cr.StressTempMin, 
                    cr.StressTempMax, 
                    cc.LocalTempAdjustment, 
                    cc.LocalHumidityAdjustment
                )
            ELSE cc.SuitabilityScore
        END AS CurrentSuitabilityScore,
        
        -- Suitability label
        CASE 
            WHEN @CurrentTemp IS NOT NULL AND @CurrentHumidity IS NOT NULL THEN
                CASE 
                    WHEN agriculture.CalculateSuitabilityScore(
                        @CurrentTemp, @CurrentHumidity, cr.OptimalTempMin, cr.OptimalTempMax, 
                        cr.OptimalHumidityMin, cr.OptimalHumidityMax, cr.StressTempMin, 
                        cr.StressTempMax, cc.LocalTempAdjustment, cc.LocalHumidityAdjustment
                    ) >= 85 THEN 'EXCELLENT'
                    WHEN agriculture.CalculateSuitabilityScore(
                        @CurrentTemp, @CurrentHumidity, cr.OptimalTempMin, cr.OptimalTempMax, 
                        cr.OptimalHumidityMin, cr.OptimalHumidityMax, cr.StressTempMin, 
                        cr.StressTempMax, cc.LocalTempAdjustment, cc.LocalHumidityAdjustment
                    ) >= 70 THEN 'VERY_GOOD'
                    WHEN agriculture.CalculateSuitabilityScore(
                        @CurrentTemp, @CurrentHumidity, cr.OptimalTempMin, cr.OptimalTempMax, 
                        cr.OptimalHumidityMin, cr.OptimalHumidityMax, cr.StressTempMin, 
                        cr.StressTempMax, cc.LocalTempAdjustment, cc.LocalHumidityAdjustment
                    ) >= 50 THEN 'FAIR'
                    WHEN agriculture.CalculateSuitabilityScore(
                        @CurrentTemp, @CurrentHumidity, cr.OptimalTempMin, cr.OptimalTempMax, 
                        cr.OptimalHumidityMin, cr.OptimalHumidityMax, cr.StressTempMin, 
                        cr.StressTempMax, cc.LocalTempAdjustment, cc.LocalHumidityAdjustment
                    ) >= 30 THEN 'POOR'
                    ELSE 'STRESS'
                END
            ELSE 
                CASE 
                    WHEN cc.SuitabilityScore >= 85 THEN 'EXCELLENT'
                    WHEN cc.SuitabilityScore >= 70 THEN 'VERY_GOOD'
                    WHEN cc.SuitabilityScore >= 50 THEN 'FAIR'
                    WHEN cc.SuitabilityScore >= 30 THEN 'POOR'
                    ELSE 'STRESS'
                END
        END AS SuitabilityLabel,
        
        -- Seasonal information
        CASE 
            WHEN cr.PlantingMonths LIKE '%"' + CAST(MONTH(GETDATE()) AS VARCHAR) + '"%' THEN 'PLANTING'
            WHEN cr.HarvestMonths LIKE '%"' + CAST(MONTH(GETDATE()) AS VARCHAR) + '"%' THEN 'HARVEST'
            ELSE 'MAINTENANCE'
        END AS CurrentSeasonActivity,
        
        -- Weather data availability indicator
        CASE 
            WHEN @CurrentTemp IS NOT NULL THEN 1
            ELSE 0
        END AS HasCurrentWeatherData,
        
        -- Color indicators for temperature (calculated in database)
        CASE 
            WHEN @CurrentTemp IS NULL THEN 'text-muted'
            WHEN @CurrentTemp >= cr.OptimalTempMin AND @CurrentTemp <= cr.OptimalTempMax THEN 'text-success'
            WHEN @CurrentTemp >= cr.StressTempMin AND @CurrentTemp <= cr.StressTempMax THEN 'text-warning'
            ELSE 'text-danger'
        END AS TemperatureColorClass,
        
        -- Color indicators for humidity (calculated in database)
        CASE 
            WHEN @CurrentHumidity IS NULL THEN 'text-muted'
            WHEN @CurrentHumidity >= cr.OptimalHumidityMin AND @CurrentHumidity <= cr.OptimalHumidityMax THEN 'text-success'
            WHEN @CurrentHumidity >= (cr.OptimalHumidityMin - 15) AND @CurrentHumidity <= (cr.OptimalHumidityMax + 15) THEN 'text-warning'
            ELSE 'text-danger'
        END AS HumidityColorClass,
        
        -- Simplified water color indicator
        'text-muted' AS WaterColorClass,
        
        -- Water requirement in Spanish
        CASE 
            WHEN LOWER(cr.WaterRequirement) = 'low' THEN 'Bajo'
            WHEN LOWER(cr.WaterRequirement) = 'medium' THEN 'Medio'
            WHEN LOWER(cr.WaterRequirement) = 'high' THEN 'Alto'
            WHEN LOWER(cr.WaterRequirement) = 'very high' THEN 'Muy Alto'
            ELSE ISNULL(cr.WaterRequirement, 'N/A')
        END AS WaterRequirementSpanish
        
    FROM weather.cities c
    INNER JOIN agriculture.CityCrops cc ON c.CityCode = cc.CityCode
    INNER JOIN agriculture.Crops cr ON cc.CropID = cr.CropID
    WHERE c.CityCode = @CityCode
      AND cr.IsActive = 1
    ORDER BY 
        CASE 
            WHEN @CurrentTemp IS NOT NULL AND @CurrentHumidity IS NOT NULL THEN
                agriculture.CalculateSuitabilityScore(
                    @CurrentTemp, @CurrentHumidity, cr.OptimalTempMin, cr.OptimalTempMax, 
                    cr.OptimalHumidityMin, cr.OptimalHumidityMax, cr.StressTempMin, 
                    cr.StressTempMax, cc.LocalTempAdjustment, cc.LocalHumidityAdjustment
                )
            ELSE cc.SuitabilityScore
        END DESC, 
        cc.IsPrimary DESC;
END;
GO
