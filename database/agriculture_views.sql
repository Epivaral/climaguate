-- Helper views for agriculture data
-- View to get crop information with normalized seasons

CREATE VIEW agriculture.vw_CropSeasons
AS
SELECT 
    c.CropID,
    c.CropCode,
    c.CropNameSpanish,
    c.CropNameEnglish,
    c.OptimalTempMin,
    c.OptimalTempMax,
    c.OptimalHumidityMin,
    c.OptimalHumidityMax,
    c.StressTempMin,
    c.StressTempMax,
    c.WaterRequirement AS WaterRequirementText,
    c.WaterRequirementMmPerWeek,
    c.GrowthCycleDays,
    c.IsActive,
    
    -- Planting months as comma-separated string
    STUFF((
        SELECT ', ' + DATENAME(MONTH, DATEFROMPARTS(2000, cs.Month, 1))
        FROM agriculture.CropSeasons cs
        WHERE cs.CropID = c.CropID AND cs.SeasonType = 'P'
        ORDER BY cs.Priority, cs.Month
        FOR XML PATH('')
    ), 1, 2, '') AS PlantingMonthsText,
    
    -- Harvest months as comma-separated string  
    STUFF((
        SELECT ', ' + DATENAME(MONTH, DATEFROMPARTS(2000, cs.Month, 1))
        FROM agriculture.CropSeasons cs
        WHERE cs.CropID = c.CropID AND cs.SeasonType = 'H'
        ORDER BY cs.Priority, cs.Month
        FOR XML PATH('')
    ), 1, 2, '') AS HarvestMonthsText,
    
    -- Planting months as JSON array (for API compatibility)
    '[' + STUFF((
        SELECT ',' + CAST(cs.Month AS NVARCHAR(2))
        FROM agriculture.CropSeasons cs
        WHERE cs.CropID = c.CropID AND cs.SeasonType = 'P'
        ORDER BY cs.Priority, cs.Month
        FOR XML PATH('')
    ), 1, 1, '') + ']' AS PlantingMonthsJson,
    
    -- Harvest months as JSON array (for API compatibility)
    '[' + STUFF((
        SELECT ',' + CAST(cs.Month AS NVARCHAR(2))
        FROM agriculture.CropSeasons cs
        WHERE cs.CropID = c.CropID AND cs.SeasonType = 'H'
        ORDER BY cs.Priority, cs.Month
        FOR XML PATH('')
    ), 1, 1, '') + ']' AS HarvestMonthsJson
    
FROM agriculture.Crops c
WHERE c.IsActive = 1;
GO

-- View to get city-crop suitability with enhanced information
CREATE VIEW agriculture.vw_CityCropSuitability
AS
SELECT 
    ci.CityCode,
    ci.CityName,
    ci.ClimateZone,
    ci.SoilType,
    ci.ElevationMeters,
    
    c.CropID,
    c.CropCode,
    c.CropNameSpanish,
    c.CropNameEnglish,
    
    cc.SuitabilityScore,
    cc.IsPrimary,
    cc.LocalTempAdjustment,
    cc.LocalHumidityAdjustment,
    cc.Notes,
    
    -- Water requirement information
    c.WaterRequirement AS WaterRequirementText,
    c.WaterRequirementMmPerWeek,
    
    -- Temperature ranges adjusted for local conditions
    c.OptimalTempMin + ISNULL(cc.LocalTempAdjustment, 0) AS LocalOptimalTempMin,
    c.OptimalTempMax + ISNULL(cc.LocalTempAdjustment, 0) AS LocalOptimalTempMax,
    c.StressTempMin + ISNULL(cc.LocalTempAdjustment, 0) AS LocalStressTempMin,
    c.StressTempMax + ISNULL(cc.LocalTempAdjustment, 0) AS LocalStressTempMax,
    
    -- Humidity ranges adjusted for local conditions
    c.OptimalHumidityMin + ISNULL(cc.LocalHumidityAdjustment, 0) AS LocalOptimalHumidityMin,
    c.OptimalHumidityMax + ISNULL(cc.LocalHumidityAdjustment, 0) AS LocalOptimalHumidityMax,
    
    -- Suitability category
    CASE 
        WHEN cc.SuitabilityScore >= 80 THEN 'Excellent'
        WHEN cc.SuitabilityScore >= 60 THEN 'Good'
        WHEN cc.SuitabilityScore >= 40 THEN 'Fair'
        WHEN cc.SuitabilityScore >= 20 THEN 'Poor'
        ELSE 'Unsuitable'
    END AS SuitabilityCategory
    
FROM weather.cities ci
INNER JOIN agriculture.CityCrops cc ON ci.CityCode = cc.CityCode
INNER JOIN agriculture.Crops c ON cc.CropID = c.CropID
WHERE c.IsActive = 1;
GO
