CREATE PROCEDURE agriculture.GetCrops
    @CropCode NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        CropNameSpanish,
        OptimalTempMin, OptimalTempMax,
        OptimalHumidityMin, OptimalHumidityMax,
        -- Convert PlantingMonths and HarvestMonths JSON to Spanish month names
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
