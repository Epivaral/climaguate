-- Post-deployment migration script for agriculture schema normalization
-- Execute backfill procedure to migrate JSON data to normalized structure

-- Check if the procedure exists before executing
IF OBJECT_ID('agriculture.usp_BackfillCropSeasons', 'P') IS NOT NULL
BEGIN
    PRINT 'Executing agriculture data normalization backfill...';
    EXEC agriculture.usp_BackfillCropSeasons;
END
ELSE
BEGIN
    PRINT 'Warning: agriculture.usp_BackfillCropSeasons procedure not found. Skipping backfill.';
END
GO

-- Create city metadata indexes for agricultural queries
-- These are optional performance enhancements
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Cities_Region' AND object_id=OBJECT_ID('weather.cities'))
    CREATE INDEX IX_Cities_Region ON weather.cities(ClimateZone, SoilType, ElevationMeters) 
    INCLUDE (CityCode, CityName, Province);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Cities_Agricultural' AND object_id=OBJECT_ID('weather.cities'))
    CREATE INDEX IX_Cities_Agricultural ON weather.cities(ElevationMeters, ClimateZone) 
    WHERE ElevationMeters IS NOT NULL;
GO
