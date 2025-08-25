CREATE PROCEDURE agriculture.GetCropsByCity
    @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get latest weather data for the city
    DECLARE @CurrentTemp FLOAT;
    DECLARE @CurrentHumidity INT;
    
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
        END AS HasCurrentWeatherData
        
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
