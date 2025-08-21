CREATE TABLE WeatherForecast (
    CityCode CHAR(3) NOT NULL,
    ForecastDate DATETIMEOFFSET,
    EffectiveDate DATETIMEOFFSET,
    Quarter INT NULL,  -- Nullable for hourly forecasts (hourly API doesn't use quarters)
    IconPhrase NVARCHAR(100),
    Phrase NVARCHAR(100),
    
    -- Temperature data (single values for hourly forecasts)
    Temperature FLOAT,           -- Actual temperature value from hourly API
    RealFeelTemperature FLOAT,   -- Actual real feel value from hourly API
    
    DewPoint FLOAT,
    RelativeHumidity INT,
    
    WindDirectionDegrees FLOAT,
    WindDirectionDescription NVARCHAR(10),
    WindSpeed FLOAT,
    
    WindGustDirectionDegrees FLOAT,
    WindGustDirectionDescription NVARCHAR(10),
    WindGustSpeed FLOAT,
    
    Visibility FLOAT,
    CloudCover INT,
    
    HasPrecipitation BIT,
    PrecipitationType NVARCHAR(20),
    PrecipitationIntensity NVARCHAR(20),
    
    PrecipitationProbability INT,
    ThunderstormProbability INT,
    
    TotalLiquid FLOAT,
    Rain FLOAT
    
);
GO

-- Index for city-specific forecast queries
CREATE INDEX IX_CityCode_ForecastDate ON WeatherForecast (CityCode, ForecastDate);
GO

-- Index for hourly forecast queries by effective date
CREATE INDEX IX_WeatherForecast_EffectiveDate ON WeatherForecast (EffectiveDate)
INCLUDE (CityCode, TemperatureAvg, PrecipitationProbability);
GO

-- Composite index for city-specific hourly queries
CREATE INDEX IX_WeatherForecast_CityCode_EffectiveDate ON WeatherForecast (CityCode, EffectiveDate)
INCLUDE (TemperatureAvg, TemperatureMin, TemperatureMax, PrecipitationProbability, RelativeHumidity);
GO