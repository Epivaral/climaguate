CREATE TABLE weather.WeatherForecast (
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
    
    WindGustSpeed FLOAT,  -- Only speed available, no direction from API
    
    Visibility FLOAT,
    CloudCover INT,
    
    HasPrecipitation BIT,
    PrecipitationType NVARCHAR(20),
    PrecipitationIntensity NVARCHAR(20),
    
    PrecipitationProbability INT,
    
    TotalLiquid FLOAT,
    Rain FLOAT
    
);
GO

-- Index for city-specific forecast queries
CREATE INDEX IX_CityCode_ForecastDate ON weather.WeatherForecast (CityCode, ForecastDate);
GO

-- Index for hourly forecast queries by effective date
CREATE INDEX IX_WeatherForecast_EffectiveDate ON weather.WeatherForecast (EffectiveDate)
INCLUDE (CityCode, Temperature, PrecipitationProbability);
GO

-- Composite index for city-specific hourly queries
CREATE INDEX IX_WeatherForecast_CityCode_EffectiveDate ON weather.WeatherForecast (CityCode, EffectiveDate)
INCLUDE (Temperature, RealFeelTemperature, PrecipitationProbability, RelativeHumidity);
GO