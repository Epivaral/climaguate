CREATE PROCEDURE agriculture.GetCropsByCity
    @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;
    
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
        
        -- Regional suitability
        cc.SuitabilityScore,
        cc.IsPrimary,
        cc.LocalTempAdjustment,
        cc.LocalHumidityAdjustment,
        cc.Notes
        
    FROM weather.cities c
    INNER JOIN agriculture.CityCrops cc ON c.CityCode = cc.CityCode
    INNER JOIN agriculture.Crops cr ON cc.CropID = cr.CropID
    WHERE c.CityCode = @CityCode
      AND cr.IsActive = 1
    ORDER BY cc.SuitabilityScore DESC, cc.IsPrimary DESC;
END;
GO
