CREATE TABLE agriculture.CityCrops (
    CityCode CHAR(3) NOT NULL,
    CropID INT NOT NULL,
    
    -- Suitability metrics (0-100 scale) - Calculated dynamically, not stored
    SuitabilityScore TINYINT NOT NULL CHECK (SuitabilityScore >= 0 AND SuitabilityScore <= 100),
    IsPrimary BIT NOT NULL DEFAULT 0,     -- Is this a main economic crop for this region?
    
    -- Regional adjustments for microclimate
    LocalTempAdjustment FLOAT DEFAULT 0 CHECK (LocalTempAdjustment BETWEEN -10.0 AND 10.0),  -- +/- degrees for local conditions
    LocalHumidityAdjustment INT DEFAULT 0 CHECK (LocalHumidityAdjustment BETWEEN -50 AND 50), -- +/- humidity for local conditions
    
    -- Additional information
    Notes NVARCHAR(200) NULL,             -- 'High altitude variety', 'Requires irrigation'
    
    
    PRIMARY KEY (CityCode, CropID),
    FOREIGN KEY (CityCode) REFERENCES weather.cities(CityCode) ON DELETE CASCADE,
    FOREIGN KEY (CropID) REFERENCES agriculture.Crops(CropID) ON DELETE CASCADE
);
GO

-- Create performance indexes
CREATE INDEX IX_CityCrops_SuitabilityScore ON agriculture.CityCrops(SuitabilityScore DESC) INCLUDE (CityCode, CropID);
GO

CREATE INDEX IX_CityCrops_IsPrimary ON agriculture.CityCrops(IsPrimary) WHERE IsPrimary = 1;
GO

CREATE INDEX IX_CityCrops_City ON agriculture.CityCrops(CityCode) INCLUDE (CropID, SuitabilityScore, IsPrimary);
GO
