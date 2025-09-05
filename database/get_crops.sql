CREATE PROCEDURE agriculture.GetCrops
    @CropCode NVARCHAR(10) -- Pass specific code OR 'ALL' for list
AS
BEGIN
    SET NOCOUNT ON;

    IF (@CropCode = 'ALL')
    BEGIN
        -- Ultra-light list for UI selectors (performance focused)
        SELECT CropCode, CropNameSpanish
        FROM agriculture.Crops
        WHERE IsActive = 1
        ORDER BY CropNameSpanish;
        RETURN;
    END

    -- Full detail for a single crop
    SELECT 
        CropNameSpanish,
        OptimalTempMin, OptimalTempMax,
        OptimalHumidityMin, OptimalHumidityMax,
        dbo.fn_MonthsJsonToSpanish(PlantingMonths) AS PlantingMonthsSpanish,
        dbo.fn_MonthsJsonToSpanish(HarvestMonths) AS HarvestMonthsSpanish,
        WaterRequirementMmPerWeek,
        dbo.fn_WaterRequirementSpanish(WaterRequirement) AS WaterRequirementSpanish,
        GrowthCycleDays,
        Description,
        CropPicture
    FROM agriculture.Crops
    WHERE CropCode = @CropCode;
END;
GO
