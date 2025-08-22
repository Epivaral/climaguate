-- Upsert statements for the cities (using MERGE to handle updates vs inserts)
MERGE weather.cities AS target
USING (VALUES
('GUA', 'Ciudad de Guatemala', 14.6349, -90.5069, 1500, 'Volcánico', 'Urbano'),
('QEZ', 'Quetzaltenango', 14.8347, -91.5180, 2330, 'Volcánico', 'Altiplano'),
('ESC', 'Escuintla', 14.3050, -90.7850, 350, 'Aluvial', 'Tierra Baja'),
('SJS', 'San Juan Sacatepéquez', 14.7188, -90.6443, 1900, 'Volcánico', 'Altiplano'),
('VIL', 'Villa Nueva', 14.5260, -90.5870, 1330, 'Volcánico', 'Tierra Media'),
('MIX', 'Mixco', 14.6333, -90.6064, 1650, 'Volcánico', 'Urbano'),
('CHM', 'Chimaltenango', 14.6611, -90.8208, 1800, 'Volcánico', 'Altiplano'),
('COB', 'Cobán', 15.4708, -90.3711, 1320, 'Volcánico', 'Altiplano'),
('HUE', 'Huehuetenango', 15.3194, -91.4708, 1900, 'Volcánico', 'Altiplano'),
('MAZ', 'Mazatenango', 14.5347, -91.5050, 370, 'Aluvial', 'Tierra Baja'),
('CHQ', 'Chiquimula', 14.8008, -89.5445, 420, 'Aluvial', 'Tierra Baja'),
('ANT', 'Antigua Guatemala', 14.5611, -90.7344, 1530, 'Volcánico', 'Altiplano'),
('PUE', 'Puerto Barrios', 15.7277, -88.5945, 3, 'Aluvial', 'Costa'),
('SLC', 'Santa Lucía Cotzumalguapa', 14.3347, -91.0264, 350, 'Aluvial', 'Tierra Baja'),
('JAL', 'Jalapa', 14.6342, -89.9911, 1360, 'Volcánico', 'Altiplano'),
('JUT', 'Jutiapa', 14.2906, -89.8958, 900, 'Volcánico', 'Tierra Media'),
('TOT', 'Totonicapán', 14.9117, -91.3720, 2500, 'Volcánico', 'Altiplano'),
('SOL', 'Sololá', 14.7739, -91.1838, 2100, 'Volcánico', 'Altiplano'),
('RET', 'Retalhuleu', 14.5361, -91.6778, 240, 'Aluvial', 'Tierra Baja'),
('SAL', 'Salamá', 15.1036, -90.3186, 940, 'Aluvial', 'Tierra Media'),
('SMC', 'San Marcos', 14.9659, -91.7944, 2400, 'Volcánico', 'Altiplano'),
('SCQ', 'Santa Cruz del Quiché', 15.0306, -91.1489, 2020, 'Volcánico', 'Altiplano'),
('ZAC', 'Zacapa', 14.9722, -89.5308, 220, 'Aluvial', 'Tierra Baja'),
('CHC', 'Chichicastenango', 14.9333, -91.1167, 2070, 'Volcánico', 'Altiplano'),
('FLO', 'Flores', 16.9254, -89.8923, 150, 'Aluvial', 'Tierra Baja'),
('AMA', 'Amatitlán', 14.4872, -90.6150, 1200, 'Volcánico', 'Tierra Media'),
('SCP', 'Santa Catarina Pinula', 14.5689, -90.4956, 1400, 'Volcánico', 'Tierra Media'),
('SAN', 'Sanarate', 14.7942, -90.1928, 780, 'Aluvial', 'Tierra Media'),
('JOC', 'Jocotenango', 14.5783, -90.7431, 1550, 'Volcánico', 'Altiplano'),
('SMP', 'San Miguel Petapa', 14.5147, -90.5536, 1250, 'Volcánico', 'Tierra Media'),
('CIC', 'Chicacao', 14.5425, -91.3739, 1100, 'Volcánico', 'Tierra Media'),
('BAR', 'Barberena', 14.3094, -90.3617, 1350, 'Volcánico', 'Tierra Media'),
('SML', 'Santa Lucía Milpas Altas', 14.5747, -90.6786, 1580, 'Volcánico', 'Altiplano'),
('SRM', 'San Raymundo', 14.7683, -90.5208, 1600, 'Volcánico', 'Altiplano'),
('GST', 'Guastatoya', 14.8536, -90.0694, 760, 'Aluvial', 'Tierra Media'),
('STE', 'Santa Elena', 16.9167, -89.8994, 160, 'Aluvial', 'Tierra Baja'),
('CUA', 'Cuilapa', 14.2769, -90.2997, 980, 'Volcánico', 'Tierra Media'),
('PAL', 'Palencia', 14.6644, -90.3594, 1380, 'Volcánico', 'Tierra Media'),
('PAT', 'Patzún', 14.6833, -91.0167, 2200, 'Volcánico', 'Altiplano'),
('ESQ', 'Esquipulas', 14.5667, -89.3500, 950, 'Aluvial', 'Tierra Media'),
('SUM', 'Sumpango', 14.6450, -90.7364, 1850, 'Volcánico', 'Altiplano'),
('CCH', 'San Pedro Carchá', 15.4711, -90.3033, 1280, 'Volcánico', 'Altiplano')
) AS source (CityCode, CityName, Latitude, Longitude, ElevationMeters, SoilType, ClimateZone)
ON target.CityCode = source.CityCode
WHEN MATCHED THEN
    UPDATE SET 
        CityName = source.CityName,
        Latitude = source.Latitude,
        Longitude = source.Longitude,
        ElevationMeters = source.ElevationMeters,
        SoilType = source.SoilType,
        ClimateZone = source.ClimateZone
WHEN NOT MATCHED THEN
    INSERT (CityCode, CityName, Latitude, Longitude, ElevationMeters, SoilType, ClimateZone)
    VALUES (source.CityCode, source.CityName, source.Latitude, source.Longitude, source.ElevationMeters, source.SoilType, source.ClimateZone);
GO



-- Truncate the icons table
TRUNCATE TABLE weather.icons;
GO

-- Insert Statements for icons
INSERT INTO weather.icons (ID, Icon, Main, Description_English, Description_Spanish, [Image], Start_Color, End_Color)
VALUES
    (200, '11d', 'Thunderstorm', 'Thunderstorm with light rain', 'Tormenta con lluvia ligera', 'rainthunderlow.png', '#1e7ce1', '#87CEEB'), 
    (201, '11d', 'Thunderstorm', 'Thunderstorm with rain', 'Tormenta con lluvia', 'rainthundermed.png', '#1e7ce1', '#87CEEB'),
    (202, '11d', 'Thunderstorm', 'Thunderstorm with heavy rain', 'Tormenta con lluvia intensa', 'rainthundermed.png', '#1e7ce1', '#87CEEB'),
    (210, '11d', 'Thunderstorm', 'Light thunderstorm', 'Tormenta ligera', 'thunder.png', '#1e7ce1', '#87CEEB'),
    (211, '11d', 'Thunderstorm', 'Thunderstorm', 'Tormenta', 'thunder.png', '#1e7ce1', '#87CEEB'),
    (212, '11d', 'Thunderstorm', 'Heavy thunderstorm', 'Tormenta intensa', 'lightning.png', '#1e7ce1', '#87CEEB'),
    (221, '11d', 'Thunderstorm', 'Ragged thunderstorm', 'Tormenta desgarrada', 'lightning.png', '#1e7ce1', '#87CEEB'),
    (230, '11d', 'Thunderstorm', 'Thunderstorm with light drizzle', 'Tormenta con llovizna ligera', 'rainthunderlow.png', '#1e7ce1', '#87CEEB'),
    (231, '11d', 'Thunderstorm', 'Thunderstorm with drizzle', 'Tormenta con llovizna', 'rainthunderlow.png', '#1e7ce1', '#87CEEB'),
    (232, '11d', 'Thunderstorm', 'Thunderstorm with heavy drizzle', 'Tormenta con llovizna intensa', 'rainthunderlow.png', '#1e7ce1', '#87CEEB'),
    (200, '11n', 'Thunderstorm', 'Thunderstorm with light rain', 'Tormenta con lluvia ligera', 'rainthunderlow.png', '#1e7ce1', '#87CEEB'), 
	(201, '11n', 'Thunderstorm', 'Thunderstorm with rain', 'Tormenta con lluvia', 'rainthundermed.png', '#1e7ce1', '#87CEEB'),
	(202, '11n', 'Thunderstorm', 'Thunderstorm with heavy rain', 'Tormenta con lluvia intensa', 'rainthundermed.png', '#1e7ce1', '#87CEEB'),
	(210, '11n', 'Thunderstorm', 'Light thunderstorm', 'Tormenta ligera', 'thunder.png', '#1e7ce1', '#87CEEB'),
	(211, '11n', 'Thunderstorm', 'Thunderstorm', 'Tormenta', 'thunder.png', '#1e7ce1', '#87CEEB'),
	(212, '11n', 'Thunderstorm', 'Heavy thunderstorm', 'Tormenta intensa', 'lightning.png', '#1e7ce1', '#87CEEB'),
	(221, '11n', 'Thunderstorm', 'Ragged thunderstorm', 'Tormenta desgarrada', 'lightning.png', '#1e7ce1', '#87CEEB'),
	(230, '11n', 'Thunderstorm', 'Thunderstorm with light drizzle', 'Tormenta con llovizna ligera', 'rainthunderlow.png', '#1e7ce1', '#87CEEB'),
	(231, '11n', 'Thunderstorm', 'Thunderstorm with drizzle', 'Tormenta con llovizna', 'rainthunderlow.png', '#1e7ce1', '#87CEEB'),
	(232, '11n', 'Thunderstorm', 'Thunderstorm with heavy drizzle', 'Tormenta con llovizna intensa', 'rainthunderlow.png', '#1e7ce1', '#87CEEB'),
    
    (300, '09d', 'Drizzle', 'Light intensity drizzle', 'Llovizna de intensidad ligera', 'rainlow.png', '#ADD8E6', '#87CEFA'), -- light blue to light sky blue
    (301, '09d', 'Drizzle', 'Drizzle', 'Llovizna', 'rainlow.png', '#ADD8E6', '#87CEFA'),
    (302, '09d', 'Drizzle', 'Heavy intensity drizzle', 'Llovizna de intensidad fuerte', 'rainlow.png', '#ADD8E6', '#87CEFA'),
    (310, '09d', 'Drizzle', 'Light intensity drizzle rain', 'Llovizna de intensidad ligera', 'rainlow.png', '#ADD8E6', '#87CEFA'),
    (311, '09d', 'Drizzle', 'Drizzle rain', 'Lluvia con llovizna', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (312, '09d', 'Drizzle', 'Heavy intensity drizzle rain', 'Lluvia con llovizna intensa', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (313, '09d', 'Drizzle', 'Shower rain and drizzle', 'Lluvia y llovizna', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (314, '09d', 'Drizzle', 'Heavy shower rain and drizzle', 'Lluvia intensa y llovizna', 'rain.png', '#ADD8E6', '#87CEFA'),
    (321, '09d', 'Drizzle', 'Shower drizzle', 'Llovizna de ducha', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (300, '09n', 'Drizzle', 'Light intensity drizzle', 'Llovizna de intensidad ligera', 'rainlow.png', '#ADD8E6', '#87CEFA'), -- light blue to light sky blue
	(301, '09n', 'Drizzle', 'Drizzle', 'Llovizna', 'rainlow.png', '#ADD8E6', '#87CEFA'),
	(302, '09n', 'Drizzle', 'Heavy intensity drizzle', 'Llovizna de intensidad fuerte', 'rainlow.png', '#ADD8E6', '#87CEFA'),
	(310, '09n', 'Drizzle', 'Light intensity drizzle rain', 'Llovizna de intensidad ligera', 'rainlow.png', '#ADD8E6', '#87CEFA'),
	(311, '09n', 'Drizzle', 'Drizzle rain', 'Lluvia con llovizna', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
	(312, '09n', 'Drizzle', 'Heavy intensity drizzle rain', 'Lluvia con llovizna intensa', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
	(313, '09n', 'Drizzle', 'Shower rain and drizzle', 'Lluvia y llovizna', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
	(314, '09n', 'Drizzle', 'Heavy shower rain and drizzle', 'Lluvia intensa y llovizna', 'rain.png', '#ADD8E6', '#87CEFA'),
	(321, '09n', 'Drizzle', 'Shower drizzle', 'Llovizna de ducha', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),


    (500, '10d', 'Rain', 'Light rain', 'Lluvia ligera', 'rainlow.png', '#bcbcbc', '#0373b8'),
    (501, '10d', 'Rain', 'Moderate rain', 'Lluvia moderada', 'rainmoderate.png', '#bcbcbc', '#0373b8'),
    (502, '10d', 'Rain', 'Heavy intensity rain', 'Lluvia de intensidad fuerte', 'rain.png', '#bcbcbc', '#0373b8'),
    (503, '10d', 'Rain', 'Very heavy rain', 'Lluvia muy intensa', 'rainheavy.png', '#bcbcbc', '#0373b8'),
    (504, '10d', 'Rain', 'Extreme rain', 'Lluvia extrema', 'rainheavy.png', '#bcbcbc', '#0373b8'),
    (511, '13d', 'Rain', 'Freezing rain', 'Lluvia helada', 'rainheavy.png', '#bcbcbc', '#0373b8'),
    (520, '09d', 'Rain', 'Light intensity shower rain', 'Lluvia de intensidad ligera', 'rainlow.png', '#bcbcbc', '#0373b8'),
    (521, '09d', 'Rain', 'Shower rain', 'Lluvia de ducha', 'rainmoderate.png', '#bcbcbc', '#0373b8'),
    (522, '09d', 'Rain', 'Heavy intensity shower rain', 'Lluvia de ducha de intensidad fuerte', 'rain.png', '#bcbcbc', '#0373b8'),
    (531, '09d', 'Rain', 'Ragged shower rain', 'Lluvia de ducha desgarrada', 'rainheavy.png', '#bcbcbc', '#0373b8'),
	(500, '10n', 'Rain', 'Light rain', 'Lluvia ligera', 'rainlow.png', '#bcbcbc', '#0373b8'),
	(501, '10n', 'Rain', 'Moderate rain', 'Lluvia moderada', 'rainmoderate.png', '#bcbcbc', '#0373b8'),
	(502, '10n', 'Rain', 'Heavy intensity rain', 'Lluvia de intensidad fuerte', 'rain.png', '#bcbcbc', '#0373b8'),
	(503, '10n', 'Rain', 'Very heavy rain', 'Lluvia muy intensa', 'rainheavy.png', '#bcbcbc', '#0373b8'),
	(504, '10n', 'Rain', 'Extreme rain', 'Lluvia extrema', 'rainheavy.png', '#bcbcbc', '#0373b8'),
	(511, '13n', 'Rain', 'Freezing rain', 'Lluvia helada', 'rainheavy.png', '#bcbcbc', '#0373b8'),
	(520, '09n', 'Rain', 'Light intensity shower rain', 'Lluvia de intensidad ligera', 'rainlow.png', '#bcbcbc', '#0373b8'),
	(521, '09n', 'Rain', 'Shower rain', 'Lluvia de ducha', 'rainmoderate.png', '#bcbcbc', '#0373b8'),
	(522, '09n', 'Rain', 'Heavy intensity shower rain', 'Lluvia de ducha de intensidad fuerte', 'rain.png', '#bcbcbc', '#0373b8'),
	(531, '09n', 'Rain', 'Ragged shower rain', 'Lluvia de ducha desgarrada', 'rainheavy.png', '#bcbcbc', '#0373b8'),

    (600, '13d', 'Snow', 'Light snow', 'Nieve ligera', 'rain.png', '#F0FFFF', '#E0FFFF'), -- azure to light cyan
    (601, '13d', 'Snow', 'Snow', 'Nieve', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (602, '13d', 'Snow', 'Heavy snow', 'Nieve intensa', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (611, '13d', 'Snow', 'Sleet', 'Aguanieve', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (612, '13d', 'Snow', 'Light shower sleet', 'Aguacero ligero', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (613, '13d', 'Snow', 'Shower sleet', 'Aguanieve', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (615, '13d', 'Snow', 'Light rain and snow', 'Lluvia ligera y nieve', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (616, '13d', 'Snow', 'Rain and snow', 'Lluvia y nieve', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (620, '13d', 'Snow', 'Light shower snow', 'Nevadas ligeras', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (621, '13d', 'Snow', 'Shower snow', 'Nevadas', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (622, '13d', 'Snow', 'Heavy shower snow', 'Nevadas intensas', 'rain.png', '#F0FFFF', '#E0FFFF'),
    (701, '50d', 'Mist', 'Mist', 'Niebla', 'haze.png', '#D3D3D3', '#C0C0C0'), 
    (711, '50d', 'Smoke', 'Smoke', 'Humo', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (721, '50d', 'Haze', 'Haze', 'Neblina', 'fog.png', '#D3D3D3', '#C0C0C0'),
    (731, '50d', 'Dust', 'Dust', 'Polvo', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (741, '50d', 'Fog', 'Fog', 'Niebla', 'fog.png', '#D3D3D3', '#C0C0C0'),
    (751, '50d', 'Sand', 'Sand', 'Arena', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (761, '50d', 'Dust', 'Dust', 'Polvo', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (762, '50d', 'Ash', 'Volcanic ash', 'Ceniza volcánica', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (771, '50d', 'Squall', 'Squalls', 'Ráfagas', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (781, '50d', 'Tornado', 'Tornado', 'Tornado', 'hurricane.png', '#D3D3D3', '#C0C0C0'),
	(701, '50n', 'Mist', 'Mist', 'Niebla', 'fog.png', '#D3D3D3', '#C0C0C0'), 
	(711, '50n', 'Smoke', 'Smoke', 'Humo', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
	(721, '50n', 'Haze', 'Haze', 'Neblina', 'fog.png', '#D3D3D3', '#C0C0C0'),
	(731, '50n', 'Dust', 'Dust', 'Polvo', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
	(741, '50n', 'Fog', 'Fog', 'Niebla', 'fog.png', '#D3D3D3', '#C0C0C0'),
	(751, '50n', 'Sand', 'Sand', 'Arena', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
	(761, '50n', 'Dust', 'Dust', 'Polvo', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
	(762, '50n', 'Ash', 'Volcanic ash', 'Ceniza volcánica', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
	(771, '50n', 'Squall', 'Squalls', 'Ráfagas', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
	(781, '50n', 'Tornado', 'Tornado', 'Tornado', 'hurricane.png', '#D3D3D3', '#C0C0C0'),
    (800, '01d', 'Clear', 'Clear sky', 'Cielo despejado', 'sunny.png', '#fb970f', '#badffb'), 
    (800, '01n', 'Clear', 'Clear sky', 'Cielo despejado', 'starrynight.png', '#00587d', '#33d6ff'),
    (801, '02d', 'Clouds', 'Few clouds: 11-25%', 'Pocas nubes: 11-25%', 'cloudy1.png', '#fb970f', '#badffb'), 
    (801, '02n', 'Clouds', 'Few clouds: 11-25%', 'Pocas nubes: 11-25%', 'cloudynight.png', '#00587d', '#33d6ff'),
    (802, '03d', 'Clouds', 'Scattered clouds: 25-50%', 'Nubes dispersas: 25-50%', 'cloudy2.png', '#fb970f', '#badffb'),
    (802, '03n', 'Clouds', 'Scattered clouds: 25-50%', 'Nubes dispersas: 25-50%', 'cloudynight.png', '#00587d', '#33d6ff'),
    (803, '04d', 'Clouds', 'Broken clouds: 51-84%', 'Nubes rotas: 51-84%', 'cloudy2.png', '#F5F5F5', '#DCDCDC'),
    (803, '04n', 'Clouds', 'Broken clouds: 51-84%', 'Nubes rotas: 51-84%', 'cloudynight.png', '#F5F5F5', '#DCDCDC'),
    (804, '04d', 'Clouds', 'Overcast clouds: 85-100%', 'Nubes cubiertas: 85-100%', 'clouds.png', '#F5F5F5', '#DCDCDC'),
    (804, '04n', 'Clouds', 'Overcast clouds: 85-100%', 'Nubes cubiertas: 85-100%', 'clouds.png', '#F5F5F5', '#DCDCDC');
GO

-- Insert sample crops data
INSERT INTO agriculture.Crops (CropCode, CropNameSpanish, CropNameEnglish, OptimalTempMin, OptimalTempMax, OptimalHumidityMin, OptimalHumidityMax, StressTempMin, StressTempMax, PlantingMonths, HarvestMonths, WaterRequirement, GrowthCycleDays, IsActive) VALUES
('CAFE', 'Café', 'Coffee', 18, 24, 60, 80, 10, 32, '["4","5"]', '["11","12","1","2"]', 'Medium', 240, 1),
('MAIZ', 'Maíz', 'Corn', 20, 30, 50, 70, 8, 38, '["5","6"]', '["9","10","11"]', 'Medium', 120, 1),
('FRIJOL', 'Frijol', 'Bean', 18, 28, 60, 75, 10, 35, '["5","6"]', '["8","9"]', 'Medium', 90, 1),
('BANANO', 'Banano', 'Banana', 26, 30, 75, 85, 15, 38, '["1","2","3","4","5","6","7","8","9","10","11","12"]', '["1","2","3","4","5","6","7","8","9","10","11","12"]', 'High', 365, 1),
('CARDAM', 'Cardamomo', 'Cardamom', 20, 25, 70, 85, 12, 32, '["3","4"]', '["11","12","1"]', 'High', 240, 1),
('CANA', 'Caña de Azúcar', 'Sugar Cane', 24, 32, 60, 80, 18, 40, '["1","2","3","4","5","6","7","8","9","10","11","12"]', '["1","2","3","4","5","6","7","8","9","10","11","12"]', 'High', 365, 1),
('PAPA', 'Papa', 'Potato', 15, 20, 65, 80, 5, 28, '["10","11"]', '["3","4","5"]', 'Medium', 120, 1),
('TOMATE', 'Tomate', 'Tomato', 18, 25, 60, 75, 10, 32, '["11","12"]', '["3","4","5"]', 'Medium', 90, 1),
('BROCOLI', 'Brócoli', 'Broccoli', 15, 22, 65, 80, 8, 28, '["10","11"]', '["2","3"]', 'Medium', 75, 1),
('AGUACAT', 'Aguacate', 'Avocado', 18, 25, 60, 75, 10, 32, '["1","2","3","4","5","6","7","8","9","10","11","12"]', '["1","2","3","4","5","6","7","8","9","10","11","12"]', 'Medium', 365, 1);
GO

-- Insert sample city-crops relationships for Guatemala City (GUA), Quetzaltenango (QEZ), and Escuintla (ESC)

-- Guatemala City (Urbano, 1500m, Volcánico) - Mixed crops suitable for medium altitude
INSERT INTO agriculture.CityCrops (CityCode, CropID, SuitabilityScore, IsPrimary, LocalTempAdjustment, LocalHumidityAdjustment, Notes) VALUES
('GUA', 1, 75, 1, 0, 0, 'Zona cafetalera cercana, buen potencial'),
('GUA', 2, 85, 1, 0, -5, 'Cultivo tradicional muy adaptado'),
('GUA', 3, 80, 1, 0, -5, 'Cultivo básico muy común'),
('GUA', 7, 70, 0, -2, 5, 'Cultivo de tierras altas cercanas'),
('GUA', 8, 75, 0, 0, -10, 'Buenas condiciones en época seca'),
('GUA', 10, 65, 0, 0, 0, 'Clima adecuado para variedades de altura');

-- Quetzaltenango (Altiplano, 2330m, Volcánico) - High altitude, cool climate crops
INSERT INTO agriculture.CityCrops (CityCode, CropID, SuitabilityScore, IsPrimary, LocalTempAdjustment, LocalHumidityAdjustment, Notes) VALUES
('QEZ', 1, 85, 1, -3, 10, 'Excelente zona cafetalera de altura'),
('QEZ', 2, 90, 1, -5, 0, 'Maíz de altura, muy productivo'),
('QEZ', 3, 85, 1, -3, 5, 'Frijol de altura, excelente calidad'),
('QEZ', 7, 95, 1, -5, 10, 'Condiciones ideales para papa'),
('QEZ', 9, 80, 0, -3, 10, 'Clima fresco ideal para brócoli'),
('QEZ', 5, 70, 0, -2, 15, 'Altitud adecuada para cardamomo');

-- Escuintla (Tierra Baja, 350m, Aluvial) - Hot, humid, tropical crops
INSERT INTO agriculture.CityCrops (CityCode, CropID, SuitabilityScore, IsPrimary, LocalTempAdjustment, LocalHumidityAdjustment, Notes) VALUES
('ESC', 4, 95, 1, 3, 10, 'Condiciones tropicales ideales'),
('ESC', 6, 90, 1, 2, 5, 'Excelente para caña de azúcar'),
('ESC', 2, 70, 1, 3, 0, 'Maíz adaptado a tierras bajas'),
('ESC', 3, 65, 0, 2, 5, 'Frijol de temporada húmeda'),
('ESC', 8, 60, 0, 2, -5, 'Solo en época seca'),
('ESC', 10, 55, 0, 3, 0, 'Variedades tropicales únicamente');
GO
