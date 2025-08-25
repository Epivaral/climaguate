-- Phase 1: Schema normalization - Create CropSeasons table
-- Replaces JSON month arrays with normalized relational structure

-- Ensure agriculture schema exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'agriculture') 
    EXEC('CREATE SCHEMA agriculture;');
GO

-- Create CropSeasons table to normalize planting/harvest months
IF OBJECT_ID('agriculture.CropSeasons', 'U') IS NULL
BEGIN
    CREATE TABLE agriculture.CropSeasons (
        CropID INT NOT NULL,
        Month TINYINT NOT NULL CHECK (Month BETWEEN 1 AND 12),
        SeasonType CHAR(1) NOT NULL CHECK (SeasonType IN ('P','H')), -- P=Planting, H=Harvest
        
        -- Optional: priority/order within season (e.g., primary vs secondary planting window)
        Priority TINYINT NOT NULL DEFAULT 1 CHECK (Priority BETWEEN 1 AND 3),
        
        -- Optional: notes for specific timing within the month
        Notes NVARCHAR(100) NULL, -- 'Early month', 'Mid-month', 'End of month'
        
        PRIMARY KEY (CropID, Month, SeasonType),
        FOREIGN KEY (CropID) REFERENCES agriculture.Crops(CropID) ON DELETE CASCADE
    );
END
GO

-- Create indexes for common queries
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CropSeasons_Month_Type' AND object_id=OBJECT_ID('agriculture.CropSeasons'))
    CREATE INDEX IX_CropSeasons_Month_Type ON agriculture.CropSeasons(Month, SeasonType) INCLUDE (CropID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_CropSeasons_Crop_Type' AND object_id=OBJECT_ID('agriculture.CropSeasons'))
    CREATE INDEX IX_CropSeasons_Crop_Type ON agriculture.CropSeasons(CropID, SeasonType) INCLUDE (Month, Priority);
GO
