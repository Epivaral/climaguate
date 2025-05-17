CREATE TABLE WeatherForecast (
    CityCode CHAR(3) NOT NULL,
    ForecastDate DATETIMEOFFSET,
    EffectiveDate DATETIMEOFFSET,
    Quarter INT,
    IconPhrase NVARCHAR(100),
    Phrase NVARCHAR(100),
    
    TemperatureMin FLOAT,
    TemperatureMax FLOAT,
    TemperatureAvg FLOAT,
    
    RealFeelMin FLOAT,
    RealFeelMax FLOAT,
    RealFeelAvg FLOAT,
    
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
