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
    
    -- Growing season information (JSON arrays for months)
    PlantingMonths NVARCHAR(20) NOT NULL, -- '["3","4"]' - March, April
    HarvestMonths NVARCHAR(20) NOT NULL,  -- '["11","12","1"]' - Nov, Dec, Jan
    
    -- Crop characteristics
    WaterRequirement NVARCHAR(20) NOT NULL, -- 'Low', 'Medium', 'High'
    GrowthCycleDays INT NOT NULL,           -- Days from planting to harvest
    
    IsActive BIT NOT NULL DEFAULT 1
);
GO
