-- Phase 1: Backfill procedure to migrate from JSON to normalized CropSeasons
-- This procedure reads PlantingMonths and HarvestMonths JSON arrays and populates CropSeasons

CREATE OR ALTER PROCEDURE agriculture.usp_BackfillCropSeasons
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowCount INT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    BEGIN TRY
        -- Check if CropSeasons table exists
        IF OBJECT_ID('agriculture.CropSeasons', 'U') IS NULL
        BEGIN
            RAISERROR('CropSeasons table does not exist. Please create it first.', 16, 1);
            RETURN;
        END
        
        -- Backfill planting seasons from JSON
        ;WITH PlantingCTE AS (
            SELECT 
                c.CropID, 
                TRY_CAST(j.[value] AS TINYINT) AS Month
            FROM agriculture.Crops c
            CROSS APPLY OPENJSON(c.PlantingMonths) j
            WHERE c.PlantingMonths IS NOT NULL 
              AND ISJSON(c.PlantingMonths) = 1
              AND TRY_CAST(j.[value] AS TINYINT) BETWEEN 1 AND 12
        )
        INSERT INTO agriculture.CropSeasons (CropID, Month, SeasonType, Priority)
        SELECT 
            p.CropID, 
            p.Month, 
            'P' AS SeasonType,
            ROW_NUMBER() OVER (PARTITION BY p.CropID ORDER BY p.Month) AS Priority
        FROM PlantingCTE p
        WHERE NOT EXISTS (
            SELECT 1 FROM agriculture.CropSeasons s
            WHERE s.CropID = p.CropID 
              AND s.Month = p.Month 
              AND s.SeasonType = 'P'
        );
        
        SET @RowCount = @@ROWCOUNT;
        PRINT 'Inserted ' + CAST(@RowCount AS NVARCHAR(10)) + ' planting season records.';
        
        -- Backfill harvest seasons from JSON
        ;WITH HarvestCTE AS (
            SELECT 
                c.CropID, 
                TRY_CAST(j.[value] AS TINYINT) AS Month
            FROM agriculture.Crops c
            CROSS APPLY OPENJSON(c.HarvestMonths) j
            WHERE c.HarvestMonths IS NOT NULL 
              AND ISJSON(c.HarvestMonths) = 1
              AND TRY_CAST(j.[value] AS TINYINT) BETWEEN 1 AND 12
        )
        INSERT INTO agriculture.CropSeasons (CropID, Month, SeasonType, Priority)
        SELECT 
            h.CropID, 
            h.Month, 
            'H' AS SeasonType,
            ROW_NUMBER() OVER (PARTITION BY h.CropID ORDER BY h.Month) AS Priority
        FROM HarvestCTE h
        WHERE NOT EXISTS (
            SELECT 1 FROM agriculture.CropSeasons s
            WHERE s.CropID = h.CropID 
              AND s.Month = h.Month 
              AND s.SeasonType = 'H'
        );
        
        SET @RowCount = @@ROWCOUNT;
        PRINT 'Inserted ' + CAST(@RowCount AS NVARCHAR(10)) + ' harvest season records.';
        
        -- Update numeric water requirements based on text values
        UPDATE agriculture.Crops 
        SET WaterRequirementMmPerWeek = 
            CASE 
                WHEN UPPER(WaterRequirement) = 'LOW' THEN 25      -- 25mm/week
                WHEN UPPER(WaterRequirement) = 'MEDIUM' THEN 50   -- 50mm/week  
                WHEN UPPER(WaterRequirement) = 'HIGH' THEN 75     -- 75mm/week
                ELSE NULL
            END
        WHERE WaterRequirementMmPerWeek IS NULL 
          AND WaterRequirement IS NOT NULL;
        
        SET @RowCount = @@ROWCOUNT;
        PRINT 'Updated ' + CAST(@RowCount AS NVARCHAR(10)) + ' water requirement records.';
        
        PRINT 'Backfill completed successfully.';
        
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Error during backfill: ' + @ErrorMessage;
        THROW;
    END CATCH
END
GO
