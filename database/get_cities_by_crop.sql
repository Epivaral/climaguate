CREATE PROCEDURE agriculture.GetCitiesByCrop
    @CropCodes NVARCHAR(MAX) -- Comma-separated list of crop codes
AS
BEGIN
    SET NOCOUNT ON;
    -- Split crop codes into table
    DECLARE @CropTable TABLE (CropCode NVARCHAR(10));
    INSERT INTO @CropTable (CropCode)
    SELECT value FROM STRING_SPLIT(@CropCodes, ',');

    -- For each crop, get top cities with suitability and info
    SELECT 
        cr.CropCode,
        cr.CropNameSpanish,
        c.CityCode,
        c.CityName,
        c.ElevationMeters,
        c.SoilType,
        c.ClimateZone,
        cc.SuitabilityScore,
        cc.IsPrimary,
        cr.PlantingMonths,
        cr.HarvestMonths,
        cr.WaterRequirement,
        cr.WaterRequirementMmPerWeek,
        cr.GrowthCycleDays
    FROM @CropTable ct
    INNER JOIN agriculture.Crops cr ON cr.CropCode = ct.CropCode
    INNER JOIN agriculture.CityCrops cc ON cr.CropID = cc.CropID
    INNER JOIN weather.cities c ON cc.CityCode = c.CityCode
    WHERE cr.IsActive = 1
    ORDER BY cr.CropCode, cc.SuitabilityScore DESC, cc.IsPrimary DESC;
END;
GO
