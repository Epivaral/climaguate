CREATE TABLE weather.cities (
    CityCode CHAR(3) NOT NULL PRIMARY KEY,
    CityName NVARCHAR(255) NOT NULL,
    Latitude FLOAT NOT NULL,
    Longitude FLOAT NOT NULL,
    ElevationMeters INT NULL,
    SoilType NVARCHAR(30) NULL,
    ClimateZone NVARCHAR(30) NULL
);
GO