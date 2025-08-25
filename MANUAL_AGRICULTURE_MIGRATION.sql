-- Manual Migration Script for Agriculture Schema Normalization
-- Run this script manually after deploying the main database project
-- This migrates JSON crop seasons data to the normalized CropSeasons table

USE [your_database_name_here];  -- Replace with your actual database name
GO

PRINT 'Starting agriculture schema migration...';
GO

-- Execute the backfill procedure if it exists
IF OBJECT_ID('agriculture.usp_BackfillCropSeasons', 'P') IS NOT NULL
BEGIN
    PRINT 'Executing agriculture data normalization backfill...';
    EXEC agriculture.usp_BackfillCropSeasons;
    PRINT 'Backfill procedure completed.';
END
ELSE
BEGIN
    PRINT 'Warning: agriculture.usp_BackfillCropSeasons procedure not found.';
    PRINT 'Please ensure the database project has been deployed first.';
END
GO

-- Create additional city metadata indexes for agricultural queries
-- These are optional performance enhancements
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Cities_Region' AND object_id=OBJECT_ID('weather.cities'))
BEGIN
    PRINT 'Creating IX_Cities_Region index...';
    CREATE INDEX IX_Cities_Region ON weather.cities(ClimateZone, SoilType, ElevationMeters) 
    INCLUDE (CityCode, CityName);
END
ELSE
BEGIN
    PRINT 'IX_Cities_Region index already exists.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Cities_Agricultural' AND object_id=OBJECT_ID('weather.cities'))
BEGIN
    PRINT 'Creating IX_Cities_Agricultural index...';
    CREATE INDEX IX_Cities_Agricultural ON weather.cities(ElevationMeters, ClimateZone) 
    WHERE ElevationMeters IS NOT NULL;
END
ELSE
BEGIN
    PRINT 'IX_Cities_Agricultural index already exists.';
END
GO

-- Verify the migration results
PRINT 'Migration verification:';

SELECT 
    'Crops with normalized seasons' AS Description,
    COUNT(DISTINCT c.CropID) AS Count
FROM agriculture.Crops c
INNER JOIN agriculture.CropSeasons cs ON c.CropID = cs.CropID;

SELECT 
    'Total season records' AS Description,
    COUNT(*) AS Count
FROM agriculture.CropSeasons;

SELECT 
    'Crops with updated water requirements' AS Description,
    COUNT(*) AS Count
FROM agriculture.Crops 
WHERE WaterRequirementMmPerWeek IS NOT NULL;

PRINT 'Agriculture schema migration completed successfully.';
GO
