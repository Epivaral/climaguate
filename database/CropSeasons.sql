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
GO

-- Create indexes for common queries
CREATE INDEX IX_CropSeasons_Month_Type ON agriculture.CropSeasons(Month, SeasonType) INCLUDE (CropID);
GO

CREATE INDEX IX_CropSeasons_Crop_Type ON agriculture.CropSeasons(CropID, SeasonType) INCLUDE (Month, Priority);
GO
