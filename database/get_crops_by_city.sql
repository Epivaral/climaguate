CREATE PROCEDURE agriculture.GetCropsByCity
    @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentTemp FLOAT;
    DECLARE @CurrentHumidity INT;
    DECLARE @CurrentRain1h FLOAT;
    DECLARE @CurrentRain3h FLOAT;
    DECLARE @CitySoilType NVARCHAR(30);

    -- Get latest weather data for the city
    SELECT TOP 1
        @CurrentTemp     = Main_Temp,
        @CurrentHumidity = Main_Humidity,
        @CurrentRain1h   = ISNULL(TRY_CAST(Rain_1h AS FLOAT), 0.0),
        @CurrentRain3h   = ISNULL(TRY_CAST(Rain_3h AS FLOAT), 0.0)
    FROM weather.WeatherData
    WHERE CityCode = @CityCode
    ORDER BY Date_gt DESC;

    -- Get soil type for the city (used for soil compatibility bonus)
    SELECT @CitySoilType = SoilType
    FROM weather.cities
    WHERE CityCode = @CityCode;

    -- CTE computes ClimateScore and SoilCompatibilityBonus once per row.
    -- The outer SELECT derives CurrentSuitabilityScore and SuitabilityLabel from
    -- those pre-computed values, avoiding repeated function calls.
    WITH CropScores AS (
        SELECT
            c.CityCode,
            c.CityName,
            c.ElevationMeters,
            c.SoilType,
            c.ClimateZone,
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
            cc.SuitabilityScore AS StaticSuitabilityScore,
            cc.IsPrimary,
            cc.LocalTempAdjustment,
            cc.LocalHumidityAdjustment,
            cc.Notes,

            -- Climate score (temperature 60% + humidity 40%, with local microclimate adjustments)
            CASE
                WHEN @CurrentTemp IS NOT NULL AND @CurrentHumidity IS NOT NULL
                THEN CAST(agriculture.CalculateSuitabilityScore(
                        @CurrentTemp, @CurrentHumidity,
                        cr.OptimalTempMin, cr.OptimalTempMax,
                        cr.OptimalHumidityMin, cr.OptimalHumidityMax,
                        cr.StressTempMin, cr.StressTempMax,
                        cc.LocalTempAdjustment, cc.LocalHumidityAdjustment
                    ) AS INT)
                ELSE CAST(cc.SuitabilityScore AS INT)
            END AS ClimateScore,

            -- Soil compatibility bonus: +5 if city soil is preferred, -8 if it should be avoided.
            -- CHARINDEX wraps both sides with commas to prevent partial-word false matches
            -- (e.g., 'Andosol' inside a hypothetical 'FluvisAndosol').
            CASE
                WHEN @CitySoilType IS NOT NULL AND cr.PreferredSoilTypes IS NOT NULL
                  AND CHARINDEX(',' + @CitySoilType + ',', ',' + cr.PreferredSoilTypes + ',') > 0
                THEN 5
                WHEN @CitySoilType IS NOT NULL AND cr.AvoidSoilTypes IS NOT NULL
                  AND CHARINDEX(',' + @CitySoilType + ',', ',' + cr.AvoidSoilTypes + ',') > 0
                THEN -8
                ELSE 0
            END AS SoilCompatibilityBonus

        FROM weather.cities c
        INNER JOIN agriculture.CityCrops cc ON c.CityCode = cc.CityCode
        INNER JOIN agriculture.Crops cr ON cc.CropID = cr.CropID
        WHERE c.CityCode = @CityCode
          AND cr.IsActive = 1
    )
    SELECT
        -- City information
        CityCode,
        CityName,
        ElevationMeters,
        SoilType,
        ClimateZone,

        -- Crop information
        CropCode,
        CropNameSpanish,
        CropNameEnglish,
        OptimalTempMin,
        OptimalTempMax,
        OptimalHumidityMin,
        OptimalHumidityMax,
        StressTempMin,
        StressTempMax,
        PlantingMonths,
        HarvestMonths,
        WaterRequirement,
        WaterRequirementMmPerWeek,
        GrowthCycleDays,

        -- Regional suitability (static expert baseline, not formula-derived)
        StaticSuitabilityScore,
        IsPrimary,
        LocalTempAdjustment,
        LocalHumidityAdjustment,
        Notes,

        -- Current weather context
        @CurrentTemp     AS CurrentTemp,
        @CurrentHumidity AS CurrentHumidity,

        -- Soil bonus exposed for UI transparency
        SoilCompatibilityBonus,

        -- Final suitability score: climate score + soil bonus, clamped 0-100
        CASE
            WHEN ClimateScore + SoilCompatibilityBonus > 100 THEN CAST(100 AS TINYINT)
            WHEN ClimateScore + SoilCompatibilityBonus < 0   THEN CAST(0   AS TINYINT)
            ELSE CAST(ClimateScore + SoilCompatibilityBonus  AS TINYINT)
        END AS CurrentSuitabilityScore,

        -- Label derived from the same final score — no repeated function calls
        CASE
            WHEN CASE WHEN ClimateScore+SoilCompatibilityBonus > 100 THEN 100
                      WHEN ClimateScore+SoilCompatibilityBonus < 0   THEN 0
                      ELSE ClimateScore+SoilCompatibilityBonus END >= 85 THEN 'EXCELLENT'
            WHEN CASE WHEN ClimateScore+SoilCompatibilityBonus > 100 THEN 100
                      WHEN ClimateScore+SoilCompatibilityBonus < 0   THEN 0
                      ELSE ClimateScore+SoilCompatibilityBonus END >= 70 THEN 'VERY_GOOD'
            WHEN CASE WHEN ClimateScore+SoilCompatibilityBonus > 100 THEN 100
                      WHEN ClimateScore+SoilCompatibilityBonus < 0   THEN 0
                      ELSE ClimateScore+SoilCompatibilityBonus END >= 50 THEN 'FAIR'
            WHEN CASE WHEN ClimateScore+SoilCompatibilityBonus > 100 THEN 100
                      WHEN ClimateScore+SoilCompatibilityBonus < 0   THEN 0
                      ELSE ClimateScore+SoilCompatibilityBonus END >= 30 THEN 'POOR'
            ELSE 'STRESS'
        END AS SuitabilityLabel,

        -- Seasonal activity (planting / harvest / maintenance)
        CASE
            WHEN PlantingMonths LIKE '%"' + CAST(MONTH(GETDATE()) AS VARCHAR) + '"%' THEN 'PLANTING'
            WHEN HarvestMonths  LIKE '%"' + CAST(MONTH(GETDATE()) AS VARCHAR) + '"%' THEN 'HARVEST'
            ELSE 'MAINTENANCE'
        END AS CurrentSeasonActivity,

        CASE WHEN @CurrentTemp IS NOT NULL THEN 1 ELSE 0 END AS HasCurrentWeatherData,

        -- Temperature color indicator
        CASE
            WHEN @CurrentTemp IS NULL THEN 'text-muted'
            WHEN @CurrentTemp >= OptimalTempMin AND @CurrentTemp <= OptimalTempMax THEN 'text-success'
            WHEN @CurrentTemp >= StressTempMin  AND @CurrentTemp <= StressTempMax  THEN 'text-warning'
            ELSE 'text-danger'
        END AS TemperatureColorClass,

        -- Humidity color indicator
        CASE
            WHEN @CurrentHumidity IS NULL THEN 'text-muted'
            WHEN @CurrentHumidity >= OptimalHumidityMin AND @CurrentHumidity <= OptimalHumidityMax THEN 'text-success'
            WHEN @CurrentHumidity >= (OptimalHumidityMin - 15) AND @CurrentHumidity <= (OptimalHumidityMax + 15) THEN 'text-warning'
            ELSE 'text-danger'
        END AS HumidityColorClass,

        -- Water requirement color indicator
        CASE
            WHEN WaterRequirement IS NULL       THEN 'text-muted'
            WHEN LOWER(WaterRequirement) = 'low'   THEN 'text-success'
            WHEN LOWER(WaterRequirement) = 'medium' THEN 'text-warning'
            WHEN LOWER(WaterRequirement) IN ('high', 'very high') THEN 'text-danger'
            ELSE 'text-muted'
        END AS WaterColorClass,

        -- Water requirement in Spanish
        CASE
            WHEN LOWER(WaterRequirement) = 'low'      THEN 'Bajo'
            WHEN LOWER(WaterRequirement) = 'medium'   THEN 'Medio'
            WHEN LOWER(WaterRequirement) = 'high'     THEN 'Alto'
            WHEN LOWER(WaterRequirement) = 'very high' THEN 'Muy Alto'
            ELSE ISNULL(WaterRequirement, 'N/A')
        END AS WaterRequirementSpanish,

        -- Rain data
        CASE WHEN @CurrentRain1h IS NOT NULL THEN CAST(@CurrentRain1h AS VARCHAR(10)) ELSE 'n/a' END AS Rain_1h,
        CASE WHEN @CurrentRain3h IS NOT NULL THEN CAST(@CurrentRain3h AS VARCHAR(10)) ELSE 'n/a' END AS Rain_3h,

        -- Water status (humidity-based)
        CASE
            WHEN @CurrentHumidity > OptimalHumidityMax THEN 'HIGH_HUMIDITY'
            WHEN @CurrentHumidity < OptimalHumidityMin THEN 'LOW_HUMIDITY'
            ELSE 'OPTIMAL_HUMIDITY'
        END AS WaterStatus

    FROM CropScores
    ORDER BY
        CASE
            WHEN ClimateScore + SoilCompatibilityBonus > 100 THEN 100
            WHEN ClimateScore + SoilCompatibilityBonus < 0   THEN 0
            ELSE ClimateScore + SoilCompatibilityBonus
        END DESC,
        IsPrimary DESC;
END;
GO
