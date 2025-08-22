CREATE TABLE agriculture.CityCrops (
    CityCode CHAR(3) NOT NULL,
    CropID INT NOT NULL,
    
    -- Suitability metrics (0-100 scale)
    SuitabilityScore TINYINT NOT NULL CHECK (SuitabilityScore >= 0 AND SuitabilityScore <= 100),
    IsPrimary BIT NOT NULL DEFAULT 0,     -- Is this a main economic crop for this region?
    
    -- Regional adjustments for microclimate
    LocalTempAdjustment FLOAT DEFAULT 0,  -- +/- degrees for local conditions
    LocalHumidityAdjustment INT DEFAULT 0, -- +/- humidity for local conditions
    
    -- Additional information
    Notes NVARCHAR(200) NULL,             -- 'High altitude variety', 'Requires irrigation'
    
    PRIMARY KEY (CityCode, CropID),
    FOREIGN KEY (CityCode) REFERENCES weather.cities(CityCode),
    FOREIGN KEY (CropID) REFERENCES agriculture.Crops(CropID)
);
GO

-- Create indexes for performance
CREATE INDEX IX_CityCrops_SuitabilityScore ON agriculture.CityCrops(SuitabilityScore DESC);
GO
CREATE INDEX IX_CityCrops_IsPrimary ON agriculture.CityCrops(IsPrimary) WHERE IsPrimary = 1;
GO
