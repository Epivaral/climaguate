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
('CHM', 'Chimaltenango', 14.6611, -90.8208),
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
('CHC', 'Chichicastenango', 14.9333, -91.1167),
('FLO', 'Flores', 16.9254, -89.8923),
('AMA', 'Amatitlán', 14.4872, -90.6150),
('SCP', 'Santa Catarina Pinula', 14.5689, -90.4956),
('SAN', 'Sanarate', 14.7942, -90.1928),
('JOC', 'Jocotenango', 14.5783, -90.7431),
('SMP', 'San Miguel Petapa', 14.5147, -90.5536),
('CIC', 'Chicacao', 14.5425, -91.3739),
('BAR', 'Barberena', 14.3094, -90.3617),
('SML', 'Santa Lucía Milpas Altas', 14.5747, -90.6786),
('SRM', 'San Raymundo', 14.7683, -90.5208),
('GST', 'Guastatoya', 14.8536, -90.0694),
('STE', 'Santa Elena', 16.9167, -89.8994),
('CUA', 'Cuilapa', 14.2769, -90.2997),
('PAL', 'Palencia', 14.6644, -90.3594),
('PAT', 'Patzún', 14.6833, -91.0167),
('ESQ', 'Esquipulas', 14.5667, -89.3500),
('SUM', 'Sumpango', 14.6450, -90.7364),
('CCH', 'San Pedro Carchá', 15.4711, -90.3033);
GO



-- Truncate the icons table
TRUNCATE TABLE weather.icons;
GO

-- Insert Statements for icons
INSERT INTO weather.icons (ID, Icon, Main, Description_English, Description_Spanish, Image, StartColor, EndColor)
VALUES
    (200, '11d', 'Thunderstorm', 'Thunderstorm with light rain', 'Tormenta con lluvia ligera', 'rainthunderlow.png', '#ADD8E6', '#87CEEB'), -- light blue to sky blue
    (201, '11d', 'Thunderstorm', 'Thunderstorm with rain', 'Tormenta con lluvia', 'rainthundermed.png', '#ADD8E6', '#87CEEB'),
    (202, '11d', 'Thunderstorm', 'Thunderstorm with heavy rain', 'Tormenta con lluvia intensa', 'rainthundermed.png', '#ADD8E6', '#87CEEB'),
    (210, '11d', 'Thunderstorm', 'Light thunderstorm', 'Tormenta ligera', 'thunder.png', '#ADD8E6', '#87CEEB'),
    (211, '11d', 'Thunderstorm', 'Thunderstorm', 'Tormenta', 'thunder.png', '#ADD8E6', '#87CEEB'),
    (212, '11d', 'Thunderstorm', 'Heavy thunderstorm', 'Tormenta intensa', 'lightning.png', '#ADD8E6', '#87CEEB'),
    (221, '11d', 'Thunderstorm', 'Ragged thunderstorm', 'Tormenta desgarrada', 'lightning.png', '#ADD8E6', '#87CEEB'),
    (230, '11d', 'Thunderstorm', 'Thunderstorm with light drizzle', 'Tormenta con llovizna ligera', 'rainthunderlow.png', '#ADD8E6', '#87CEEB'),
    (231, '11d', 'Thunderstorm', 'Thunderstorm with drizzle', 'Tormenta con llovizna', 'rainthunderlow.png', '#ADD8E6', '#87CEEB'),
    (232, '11d', 'Thunderstorm', 'Thunderstorm with heavy drizzle', 'Tormenta con llovizna intensa', 'rainthunderlow.png', '#ADD8E6', '#87CEEB'),
    (300, '09d', 'Drizzle', 'Light intensity drizzle', 'Llovizna de intensidad ligera', 'rainlow.png', '#ADD8E6', '#87CEFA'), -- light blue to light sky blue
    (301, '09d', 'Drizzle', 'Drizzle', 'Llovizna', 'rainlow.png', '#ADD8E6', '#87CEFA'),
    (302, '09d', 'Drizzle', 'Heavy intensity drizzle', 'Llovizna de intensidad fuerte', 'rainlow.png', '#ADD8E6', '#87CEFA'),
    (310, '09d', 'Drizzle', 'Light intensity drizzle rain', 'Llovizna de intensidad ligera', 'rainlow.png', '#ADD8E6', '#87CEFA'),
    (311, '09d', 'Drizzle', 'Drizzle rain', 'Lluvia con llovizna', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (312, '09d', 'Drizzle', 'Heavy intensity drizzle rain', 'Lluvia con llovizna intensa', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (313, '09d', 'Drizzle', 'Shower rain and drizzle', 'Lluvia y llovizna', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (314, '09d', 'Drizzle', 'Heavy shower rain and drizzle', 'Lluvia intensa y llovizna', 'rain.png', '#ADD8E6', '#87CEFA'),
    (321, '09d', 'Drizzle', 'Shower drizzle', 'Llovizna de ducha', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (500, '10d', 'Rain', 'Light rain', 'Lluvia ligera', 'rainlow.png', '#ADD8E6', '#87CEFA'),
    (501, '10d', 'Rain', 'Moderate rain', 'Lluvia moderada', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (502, '10d', 'Rain', 'Heavy intensity rain', 'Lluvia de intensidad fuerte', 'rain.png', '#ADD8E6', '#87CEFA'),
    (503, '10d', 'Rain', 'Very heavy rain', 'Lluvia muy intensa', 'rainheavy.png', '#ADD8E6', '#87CEFA'),
    (504, '10d', 'Rain', 'Extreme rain', 'Lluvia extrema', 'rainheavy.png', '#ADD8E6', '#87CEFA'),
    (511, '13d', 'Rain', 'Freezing rain', 'Lluvia helada', 'rainheavy.png', '#ADD8E6', '#87CEFA'),
    (520, '09d', 'Rain', 'Light intensity shower rain', 'Lluvia de intensidad ligera', 'rainlow.png', '#ADD8E6', '#87CEFA'),
    (521, '09d', 'Rain', 'Shower rain', 'Lluvia de ducha', 'rainmoderate.png', '#ADD8E6', '#87CEFA'),
    (522, '09d', 'Rain', 'Heavy intensity shower rain', 'Lluvia de ducha de intensidad fuerte', 'rain.png', '#ADD8E6', '#87CEFA'),
    (531, '09d', 'Rain', 'Ragged shower rain', 'Lluvia de ducha desgarrada', 'rainheavy.png', '#ADD8E6', '#87CEFA'),
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
    (701, '50d', 'Mist', 'Mist', 'Niebla', 'haze.png', '#D3D3D3', '#C0C0C0'), -- light gray to silver
    (711, '50d', 'Smoke', 'Smoke', 'Humo', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (721, '50d', 'Haze', 'Haze', 'Neblina', 'fog.png', '#D3D3D3', '#C0C0C0'),
    (731, '50d', 'Dust', 'Dust', 'Polvo', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (741, '50d', 'Fog', 'Fog', 'Niebla', 'fog.png', '#D3D3D3', '#C0C0C0'),
    (751, '50d', 'Sand', 'Sand', 'Arena', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (761, '50d', 'Dust', 'Dust', 'Polvo', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (762, '50d', 'Ash', 'Volcanic ash', 'Ceniza volcánica', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (771, '50d', 'Squall', 'Squalls', 'Ráfagas', 'windcloudy.png', '#D3D3D3', '#C0C0C0'),
    (781, '50d', 'Tornado', 'Tornado', 'Tornado', 'hurricane.png', '#D3D3D3', '#C0C0C0'),
    (800, '01d', 'Clear', 'Clear sky', 'Cielo despejado', 'sunny.png', '#FFD700', '#FFA500'), -- gold to orange
    (800, '01n', 'Clear', 'Clear sky', 'Cielo despejado', 'starrynight.png', '#FFD700', '#FFA500'),
    (801, '02d', 'Clouds', 'Few clouds: 11-25%', 'Pocas nubes: 11-25%', 'cloudy1.png', '#F5F5F5', '#DCDCDC'), -- white smoke to gainsboro
    (801, '02n', 'Clouds', 'Few clouds: 11-25%', 'Pocas nubes: 11-25%', 'cloudynight.png', '#F5F5F5', '#DCDCDC'),
    (802, '03d', 'Clouds', 'Scattered clouds: 25-50%', 'Nubes dispersas: 25-50%', 'cloudy2.png', '#F5F5F5', '#DCDCDC'),
    (802, '03n', 'Clouds', 'Scattered clouds: 25-50%', 'Nubes dispersas: 25-50%', 'cloudynight.png', '#F5F5F5', '#DCDCDC'),
    (803, '04d', 'Clouds', 'Broken clouds: 51-84%', 'Nubes rotas: 51-84%', 'cloudy2.png', '#F5F5F5', '#DCDCDC'),
    (803, '04n', 'Clouds', 'Broken clouds: 51-84%', 'Nubes rotas: 51-84%', 'cloudynight.png', '#F5F5F5', '#DCDCDC'),
    (804, '04d', 'Clouds', 'Overcast clouds: 85-100%', 'Nubes cubiertas: 85-100%', 'clouds.png', '#F5F5F5', '#DCDCDC'),
    (804, '04n', 'Clouds', 'Overcast clouds: 85-100%', 'Nubes cubiertas: 85-100%', 'clouds.png', '#F5F5F5', '#DCDCDC');
GO
