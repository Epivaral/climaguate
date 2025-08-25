-- Phase 1: Schema normalization - Create Crops table with idempotent checks
-- Check if schema exists, create if not
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'agriculture') 
    EXEC('CREATE SCHEMA agriculture;');
GO

-- Create Crops table with enhanced structure
IF OBJECT_ID('agriculture.Crops', 'U') IS NULL
BEGIN
    CREATE TABLE agriculture.Crops (
        CropID INT IDENTITY(1,1) PRIMARY KEY,
        CropCode NVARCHAR(10) NOT NULL UNIQUE,
        CropNameSpanish NVARCHAR(50) NOT NULL,
        CropNameEnglish NVARCHAR(50) NOT NULL,
        
        -- Optimal growing conditions for Guatemala
        OptimalTempMin FLOAT NOT NULL,        -- Minimum optimal temperature (°C)
        OptimalTempMax FLOAT NOT NULL,        -- Maximum optimal temperature (°C)
        OptimalHumidityMin INT NOT NULL,      -- Minimum optimal humidity (%)
        OptimalHumidityMax INT NOT NULL,      -- Maximum optimal humidity (%)
        
        -- Critical thresholds for stress calculations
        StressTempMin FLOAT NOT NULL,         -- Below this = cold stress
        StressTempMax FLOAT NOT NULL,         -- Above this = heat stress
        
        -- Growing season information (JSON arrays for months) - Legacy, will be normalized
        PlantingMonths NVARCHAR(100) NOT NULL, -- '["3","4"]' - March, April
        HarvestMonths NVARCHAR(100) NOT NULL,  -- '["11","12","1"]' - Nov, Dec, Jan
        
        -- Crop characteristics
        WaterRequirement NVARCHAR(20) NOT NULL, -- 'Low', 'Medium', 'High' - Legacy
        WaterRequirementMmPerWeek SMALLINT NULL, -- Numeric water requirement (10-120 mm/week)
        GrowthCycleDays INT NOT NULL,           -- Days from planting to harvest
        
        IsActive BIT NOT NULL DEFAULT 1
    );
END
GO

-- Add numeric water requirement column if it doesn't exist
IF COL_LENGTH('agriculture.Crops','WaterRequirementMmPerWeek') IS NULL
    ALTER TABLE agriculture.Crops ADD WaterRequirementMmPerWeek SMALLINT NULL; -- e.g., 10..120
GO

-- Add constraints for data integrity (check existence first)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Crops_OptimalRanges' AND parent_object_id = OBJECT_ID('agriculture.Crops'))
    ALTER TABLE agriculture.Crops
        WITH CHECK ADD CONSTRAINT CK_Crops_OptimalRanges
        CHECK (OptimalTempMin < OptimalTempMax AND OptimalHumidityMin < OptimalHumidityMax);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Crops_StressRanges' AND parent_object_id = OBJECT_ID('agriculture.Crops'))
    ALTER TABLE agriculture.Crops
        WITH CHECK ADD CONSTRAINT CK_Crops_StressRanges
        CHECK (StressTempMin < StressTempMax AND StressTempMin <= OptimalTempMin AND StressTempMax >= OptimalTempMax);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Crops_WaterRequirement' AND parent_object_id = OBJECT_ID('agriculture.Crops'))
    ALTER TABLE agriculture.Crops
        WITH CHECK ADD CONSTRAINT CK_Crops_WaterRequirement
        CHECK (WaterRequirementMmPerWeek IS NULL OR WaterRequirementMmPerWeek BETWEEN 10 AND 120);
GO

-- Create performance indexes if they don't exist
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Crops_Code' AND object_id=OBJECT_ID('agriculture.Crops'))
    CREATE INDEX IX_Crops_Code ON agriculture.Crops(CropCode) INCLUDE (CropNameSpanish, CropNameEnglish);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Crops_Active' AND object_id=OBJECT_ID('agriculture.Crops'))
    CREATE INDEX IX_Crops_Active ON agriculture.Crops(IsActive) WHERE IsActive = 1;
GO
