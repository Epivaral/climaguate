-- Insert statements for the cities
TRUNCATE TABLE weather.cities;
GO
INSERT INTO weather.cities (CityCode, CityName, Latitude, Longitude) VALUES
('GUA', 'Ciudad de Guatemala', 14.6349, -90.5069),
('QEZ', 'Quetzaltenango', 14.8347, -91.5180),
('ESC', 'Escuintla', 14.3050, -90.7850),
('SJS', 'San Juan Sacatepéquez', 14.7188, -90.6443),
('VIL', 'Villa Nueva', 14.5260, -90.5870),
('MIX', 'Mixco', 14.6333, -90.6064),
('CHI', 'Chimaltenango', 14.6611, -90.8208),
('COB', 'Cobán', 15.4708, -90.3711),
('HUE', 'Huehuetenango', 15.3194, -91.4708),
('MAZ', 'Mazatenango', 14.5347, -91.5050),
('CHQ', 'Chiquimula', 14.8008, -89.5445),
('ANT', 'Antigua Guatemala', 14.5611, -90.7344),
('PUE', 'Puerto Barrios', 15.7277, -88.5945),
('SLC', 'Santa Lucía Cotzumalguapa', 14.3347, -91.0264),
('JAL', 'Jalapa', 14.6342, -89.9911),
('JUT', 'Jutiapa', 14.2906, -89.8958),
('TOT', 'Totonicapán', 14.9117, -91.3720),
('SOL', 'Sololá', 14.7739, -91.1838),
('RET', 'Retalhuleu', 14.5361, -91.6778),
('SAL', 'Salamá', 15.1036, -90.3186),
('SMC', 'San Marcos', 14.9659, -91.7944),
('SCQ', 'Santa Cruz del Quiché', 15.0306, -91.1489),
('ZAC', 'Zacapa', 14.9722, -89.5308),
('CHC', 'Chichicastenango', 14.9333, -91.1167);
GO

-- Truncate the icons table
TRUNCATE TABLE weather.icons;
GO

-- Insert Statements for icons
INSERT INTO weather.icons (ID, Icon, Main, Description_English, Description_Spanish, Image, Start_Color, End_Color)
VALUES
    (200, '11d', 'Thunderstorm', 'Thunderstorm with light rain', 'Tormenta con lluvia ligera', 'rainthunderlow.png', '#483D8B', '#2F4F4F'), -- dark slate blue to dark slate gray
    (201, '11d', 'Thunderstorm', 'Thunderstorm with rain', 'Tormenta con lluvia', 'rainthundermed.png', '#483D8B', '#2F4F4F'),
    (202, '11d', 'Thunderstorm', 'Thunderstorm with heavy rain', 'Tormenta con lluvia intensa', 'rainthundermed.png', '#483D8B', '#2F4F4F'),
    (210, '11d', 'Thunderstorm', 'Light thunderstorm', 'Tormenta ligera', 'thunder.png', '#483D8B', '#2F4F4F'),
    (211, '11d', 'Thunderstorm', 'Thunderstorm', 'Tormenta', 'thunder.png', '#483D8B', '#2F4F4F'),
    (212, '11d', 'Thunderstorm', 'Heavy thunderstorm', 'Tormenta intensa', 'lightning.png', '#483D8B', '#2F4F4F'),
    (221, '11d', 'Thunderstorm', 'Ragged thunderstorm', 'Tormenta desgarrada', 'lightning.png', '#483D8B', '#2F4F4F'),
    (230, '11d', 'Thunderstorm', 'Thunderstorm with light drizzle', 'Tormenta con llovizna ligera', 'rainthunderlow.png', '#483D8B', '#2F4F4F'),
    (231, '11d', 'Thunderstorm', 'Thunderstorm with drizzle', 'Tormenta con llovizna', 'rainthunderlow.png', '#483D8B', '#2F4F4F'),
    (232, '11d', 'Thunderstorm', 'Thunderstorm with heavy drizzle', 'Tormenta con llovizna intensa', 'rainthunderlow.png', '#483D8B', '#2F4F4F'),
    (300, '09d', 'Drizzle', 'Light intensity drizzle', 'Llovizna de intensidad ligera', 'rainlow.png', '#00CED1', '#20B2AA'), -- dark turquoise to light sea green
    (301, '09d', 'Drizzle', 'Drizzle', 'Llovizna', 'rainlow.png', '#00CED1', '#20B2AA'),
    (302, '09d', 'Drizzle', 'Heavy intensity drizzle', 'Llovizna de intensidad fuerte', 'rainlow.png', '#00CED1', '#20B2AA'),
    (310, '09d', 'Drizzle', 'Light intensity drizzle rain', 'Llovizna de intensidad ligera', 'rainlow.png', '#00CED1', '#20B2AA'),
    (311, '09d', 'Drizzle', 'Drizzle rain', 'Lluvia con llovizna', 'rainmoderate.png', '#00CED1', '#20B2AA'),
    (312, '09d', 'Drizzle', 'Heavy intensity drizzle rain', 'Lluvia con llovizna intensa', 'rainmoderate.png', '#00CED1', '#20B2AA'),
    (313, '09d', 'Drizzle', 'Shower rain and drizzle', 'Lluvia y llovizna', 'rainmoderate.png', '#00CED1', '#20B2AA'),
    (314, '09d', 'Drizzle', 'Heavy shower rain and drizzle', 'Lluvia intensa y llovizna', 'rain.png', '#00CED1', '#20B2AA'),
    (321, '09d', 'Drizzle', 'Shower drizzle', 'Llovizna de ducha', 'rainmoderate.png', '#00CED1', '#20B2AA'),
    (500, '10d', 'Rain', 'Light rain', 'Lluvia ligera', 'rainlow.png', '#4682B4', '#000080'), -- steel blue to navy
    (501, '10d', 'Rain', 'Moderate rain', 'Lluvia moderada', 'rainmoderate.png', '#4682B4', '#000080'),
    (502, '10d', 'Rain', 'Heavy intensity rain', 'Lluvia de intensidad fuerte', 'rain.png', '#4682B4', '#000080'),
    (503, '10d', 'Rain', 'Very heavy rain', 'Lluvia muy intensa', 'rainheavy.png', '#4682B4', '#000080'),
    (504, '10d', 'Rain', 'Extreme rain', 'Lluvia extrema', 'rainheavy.png', '#4682B4', '#000080'),
    (511, '13d', 'Rain', 'Freezing rain', 'Lluvia helada', 'rainheavy.png', '#4682B4', '#000080'),
    (520, '09d', 'Rain', 'Light intensity shower rain', 'Lluvia de intensidad ligera', 'rainlow.png', '#4682B4', '#000080'),
    (521, '09d', 'Rain', 'Shower rain', 'Lluvia de ducha', 'rainmoderate.png', '#4682B4', '#000080'),
    (522, '09d', 'Rain', 'Heavy intensity shower rain', 'Lluvia de ducha de intensidad fuerte', 'rain.png', '#4682B4', '#000080'),
    (531, '09d', 'Rain', 'Ragged shower rain', 'Lluvia de ducha desgarrada', 'rainheavy.png', '#4682B4', '#000080'),
    (600, '13d', 'Snow', 'Light snow', 'Nieve ligera', 'rain.png', '#FFFFFF', '#00BFFF'), -- white to deep sky blue
    (601, '13d', 'Snow', 'Snow', 'Nieve', 'rain.png', '#FFFFFF', '#00BFFF'),
    (602, '13d', 'Snow', 'Heavy snow', 'Nieve intensa', 'rain.png', '#FFFFFF', '#00BFFF'),
    (611, '13d', 'Snow', 'Sleet', 'Aguanieve', 'rain.png', '#FFFFFF', '#00BFFF'),
    (612, '13d', 'Snow', 'Light shower sleet', 'Aguacero ligero', 'rain.png', '#FFFFFF', '#00BFFF'),
    (613, '13d', 'Snow', 'Shower sleet', 'Aguanieve', 'rain.png', '#FFFFFF', '#00BFFF'),
    (615, '13d', 'Snow', 'Light rain and snow', 'Lluvia ligera y nieve', 'rain.png', '#FFFFFF', '#00BFFF'),
    (616, '13d', 'Snow', 'Rain and snow', 'Lluvia y nieve', 'rain.png', '#FFFFFF', '#00BFFF'),
    (620, '13d', 'Snow', 'Light shower snow', 'Nevadas ligeras', 'rain.png', '#FFFFFF', '#00BFFF'),
    (621, '13d', 'Snow', 'Shower snow', 'Nevadas', 'rain.png', '#FFFFFF', '#00BFFF'),
    (622, '13d', 'Snow', 'Heavy shower snow', 'Nevadas intensas', 'rain.png', '#FFFFFF', '#00BFFF'),
    (701, '50d', 'Mist', 'Mist', 'Niebla', 'haze.png', '#F5F5F5', '#A9A9A9'), -- white smoke to dark gray
    (711, '50d', 'Smoke', 'Smoke', 'Humo', 'windcloudy.png', '#F5F5F5', '#A9A9A9'),
    (721, '50d', 'Haze', 'Haze', 'Neblina', 'fog.png', '#F5F5F5', '#A9A9A9'),
    (731, '50d', 'Dust', 'Dust', 'Polvo', 'windcloudy.png', '#F5F5F5', '#A9A9A9'),
    (741, '50d', 'Fog', 'Fog', 'Niebla', 'fog.png', '#F5F5F5', '#A9A9A9'),
    (751, '50d', 'Sand', 'Sand', 'Arena', 'windcloudy.png', '#F5F5F5', '#A9A9A9'),
    (761, '50d', 'Dust', 'Dust', 'Polvo', 'windcloudy.png', '#F5F5F5', '#A9A9A9'),
    (762, '50d', 'Ash', 'Volcanic ash', 'Ceniza volcánica', 'windcloudy.png', '#F5F5F5', '#A9A9A9'),
    (771, '50d', 'Squall', 'Squalls', 'Ráfagas', 'windcloudy.png', '#F5F5F5', '#A9A9A9'),
    (781, '50d', 'Tornado', 'Tornado', 'Tornado', 'hurricane.png', '#F5F5F5', '#A9A9A9'),
    (800, '01d', 'Clear', 'Clear sky', 'Cielo despejado', 'sunny.png', '#FFD700', '#FF4500'), -- gold to orange-red
    (800, '01n', 'Clear', 'Clear sky', 'Cielo despejado', 'starrynight.png', '#FFD700', '#FF4500'),
    (801, '02d', 'Clouds', 'Few clouds: 11-25%', 'Pocas nubes: 11-25%', 'cloudy1.png', '#87CEEB', '#4682B4'), -- sky blue to steel blue
    (801, '02n', 'Clouds', 'Few clouds: 11-25%', 'Pocas nubes: 11-25%', 'cloudynight.png', '#87CEEB', '#4682B4'),
    (802, '03d', 'Clouds', 'Scattered clouds: 25-50%', 'Nubes dispersas: 25-50%', 'cloudy2.png', '#B0C4DE', '#778899'), -- light steel blue to light slate gray
    (802, '03n', 'Clouds', 'Scattered clouds: 25-50%', 'Nubes dispersas: 25-50%', 'cloudynight.png', '#B0C4DE', '#778899'),
    (803, '04d', 'Clouds', 'Broken clouds: 51-84%', 'Nublado: 51-84%', 'cloudy2.png', '#A9A9A9', '#696969'), -- dark gray to dim gray
    (803, '04n', 'Clouds', 'Broken clouds: 51-84%', 'Nublado: 51-84%', 'cloudynight.png', '#A9A9A9', '#696969'),
    (804, '04d', 'Clouds', 'Overcast clouds: 85-100%', 'Nubes cubiertas: 85-100%', 'clouds.png', '#A9A9A9', '#696969'),
    (804, '04n', 'Clouds', 'Overcast clouds: 85-100%', 'Nubes cubiertas: 85-100%', 'clouds.png', '#A9A9A9', '#696969');
