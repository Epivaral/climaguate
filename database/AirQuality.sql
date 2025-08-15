CREATE TABLE [weather].[AirQuality] (
    [Id]            INT IDENTITY (1, 1) NOT NULL,
    [CityCode]      NVARCHAR (10)       NOT NULL,
    [CityName]      NVARCHAR (100)      NOT NULL,
    [Latitude]      DECIMAL (9, 6)      NOT NULL,
    [Longitude]     DECIMAL (9, 6)      NOT NULL,
    [AQI]           INT                 NOT NULL,    -- Air Quality Index (1-5)
    [Category]      NVARCHAR (50)       NOT NULL,    -- Good, Fair, Moderate, Poor, Very Poor
    [CO]            DECIMAL (10, 2)     NULL,        -- Carbon monoxide (μg/m³)
    [NO]            DECIMAL (10, 2)     NULL,        -- Nitrogen monoxide (μg/m³)
    [NO2]           DECIMAL (10, 2)     NULL,        -- Nitrogen dioxide (μg/m³)
    [O3]            DECIMAL (10, 2)     NULL,        -- Ozone (μg/m³)
    [SO2]           DECIMAL (10, 2)     NULL,        -- Sulphur dioxide (μg/m³)
    [PM2_5]         DECIMAL (10, 2)     NULL,        -- Fine particles (μg/m³)
    [PM10]          DECIMAL (10, 2)     NULL,        -- Coarse particles (μg/m³)
    [NH3]           DECIMAL (10, 2)     NULL,        -- Ammonia (μg/m³)
    [Timestamp]     INT                 NOT NULL,    -- Unix timestamp from API
    [Date_gt]       DATETIMEOFFSET (7)  NOT NULL,    -- Converted Guatemala time
    [CreatedAt]     DATETIME2 (7)       CONSTRAINT [DF_AirQuality_CreatedAt] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_AirQuality] PRIMARY KEY CLUSTERED ([Id] ASC)
);

-- Index for efficient city-based queries
CREATE NONCLUSTERED INDEX [IX_AirQuality_CityCode_Date] 
ON [weather].[AirQuality] ([CityCode] ASC, [Date_gt] DESC);

-- Index for time-based queries
CREATE NONCLUSTERED INDEX [IX_AirQuality_Date] 
ON [weather].[AirQuality] ([Date_gt] DESC);
