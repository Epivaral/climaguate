-- Phase 1: Schema normalization - Create CityCrops table with idempotent checks
-- Ensures agriculture schema exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'agriculture') 
    EXEC('CREATE SCHEMA agriculture;');
GO

-- Create CityCrops table with enhanced structure
IF OBJECT_ID('agriculture.CityCrops', 'U') IS NULL
BEGIN
    CREATE TABLE agriculture.CityCrops (
        CityCode CHAR(3) NOT NULL,
        CropID INT NOT NULL,
        
        -- Suitability metrics (0-100 scale) - Calculated dynamically, not stored
        SuitabilityScore TINYINT NOT NULL CHECK (SuitabilityScore >= 0 AND SuitabilityScore <= 100),
        IsPrimary BIT NOT NULL DEFAULT 0,     -- Is this a main economic crop for this region?
        
        -- Regional adjustments for microclimate
        LocalTempAdjustment FLOAT DEFAULT 0,  -- +/- degrees for local conditions
        LocalHumidityAdjustment INT DEFAULT 0, -- +/- humidity for local conditions
        
        -- Additional information
        Notes NVARCHAR(200) NULL,             -- 'High altitude variety', 'Requires irrigation'
        
        -- Audit fields
        CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
        
        PRIMARY KEY (CityCode, CropID),
        FOREIGN KEY (CityCode) REFERENCES weather.cities(CityCode) ON DELETE CASCADE,
        FOREIGN KEY (CropID) REFERENCES agriculture.Crops(CropID) ON DELETE CASCADE
    );
END
GO

-- Add constraints for data integrity (check existence first)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CityCrops_TempAdjustment' AND parent_object_id = OBJECT_ID('agriculture.CityCrops'))
    ALTER TABLE agriculture.CityCrops
        WITH CHECK ADD CONSTRAINT CK_CityCrops_TempAdjustment
        CHECK (LocalTempAdjustment BETWEEN -10.0 AND 10.0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_CityCrops_HumidityAdjustment' AND parent_object_id = OBJECT_ID('agriculture.CityCrops'))
    ALTER TABLE agriculture.CityCrops
        WITH CHECK ADD CONSTRAINT CK_CityCrops_HumidityAdjustment
        CHECK (LocalHumidityAdjustment BETWEEN -50 AND 50);
GO

-- Create performance indexes if they don't exist
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CityCrops_SuitabilityScore' AND object_id=OBJECT_ID('agriculture.CityCrops'))
    CREATE INDEX IX_CityCrops_SuitabilityScore ON agriculture.CityCrops(SuitabilityScore DESC) INCLUDE (CityCode, CropID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CityCrops_IsPrimary' AND object_id=OBJECT_ID('agriculture.CityCrops'))
    CREATE INDEX IX_CityCrops_IsPrimary ON agriculture.CityCrops(IsPrimary) WHERE IsPrimary = 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CityCrops_City' AND object_id=OBJECT_ID('agriculture.CityCrops'))
    CREATE INDEX IX_CityCrops_City ON agriculture.CityCrops(CityCode) INCLUDE (CropID, SuitabilityScore, IsPrimary);
GO

-- City metadata indexes for agricultural queries
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Cities_Region' AND object_id=OBJECT_ID('weather.cities'))
    CREATE INDEX IX_Cities_Region ON weather.cities(ClimateZone, SoilType, ElevationMeters) 
    INCLUDE (CityCode, CityName, Province);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Cities_Agricultural' AND object_id=OBJECT_ID('weather.cities'))
    CREATE INDEX IX_Cities_Agricultural ON weather.cities(ElevationMeters, ClimateZone) 
    WHERE ElevationMeters IS NOT NULL;
GO
