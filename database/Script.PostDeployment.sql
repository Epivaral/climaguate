-- Upsert statements for the cities (using MERGE to handle updates vs inserts)
MERGE weather.cities AS target
USING (VALUES
('GUA','Ciudad de Guatemala',14.6349,-90.5069,1500,'Andosol','Cwa'),
('QEZ','Quetzaltenango',14.8347,-91.5180,2333,'Andosol','Cwb'),
('SJS','San Juan Sacatepéquez',14.7188,-90.6443,1447,'Andosol','Cwb'),
('VIL','Villa Nueva',14.5260,-90.5870,1250,'Andosol','Cwa'),
('MIX','Mixco',14.6333,-90.6064,1600,'Andosol','Cwb'),
('CHM','Chimaltenango',14.6611,-90.8208,1810,'Andosol','Cwb'),
('COB','Cobán',15.4708,-90.3711,1325,'Andosol','Am'),
('HUE','Huehuetenango',15.3194,-91.4708,1890,'Andosol','Cwb'),
('ANT','Antigua Guatemala',14.5611,-90.7344,1533,'Andosol','Cwb'),
('TOT','Totonicapán',14.9117,-91.3720,2350,'Andosol','Cwb'),
('SOL','Sololá',14.7739,-91.1838,2000,'Andosol','Cwb'),
('SMC','San Marcos',14.9659,-91.7944,2280,'Andosol','Cwb'),
('SCQ','Santa Cruz del Quiché',15.0306,-91.1489,2020,'Andosol','Cwb'),
('CHC','Chichicastenango',14.9333,-91.1167,2050,'Andosol','Cwb'),
('PAT','Patzún',14.6833,-91.0167,2200,'Andosol','Cwb'),
('ESC','Escuintla',14.3050,-90.7850,346,'Acrisols', 'Aw'),
('MAZ','Mazatenango',14.5347,-91.5050,365,'Fluvisols','Aw'),
('ZAC','Zacapa',14.9722,-89.5308,220,'Fluvisols','Aw'),
('PUE','Puerto Barrios',15.7277,-88.5945,5,'Fluvisols','Af'),
('SLC','Santa Lucía Cotzumalguapa',14.3347,-91.0264,275,'Fluvisols','Aw'),
('JUT','Jutiapa',14.2906,-89.8958,900,'Regosols','Aw'),
('RET','Retalhuleu',14.5361,-91.6778,240,'Fluvisols','Aw'),
('SAL','Salamá',15.1036,-90.3186,940,'Regosols','Aw'),
('FLO','Flores',16.9254,-89.8923,150,'Fluvisols','Aw'),
('SAN','Sanarate',14.7942,-90.1928,780,'Fluvisols','Aw'),
('AMA','Amatitlán',14.4872,-90.6150,1200,'Andosol','Cwa'),
('SCP','Santa Catarina Pinula',14.5689,-90.4956,1350,'Andosol','Cwa'),
('JOC','Jocotenango',14.5783,-90.7431,1550,'Andosol','Cwb'),
('SMP','San Miguel Petapa',14.5147,-90.5536,1250,'Andosol','Cwa'),
('CIC','Chicacao',14.5425,-91.3739,1100,'Andosol','Cwa'),
('BAR','Barberena',14.3094,-90.3617,1350,'Andosol','Cwa'),
('SML','Santa Lucía Milpas Altas',14.5747,-90.6786,1550,'Andosol','Cwb'),
('SRM','San Raymundo',14.7683,-90.5208,1600,'Andosol','Cwb'),
('GST','Guastatoya',14.8536,-90.0694,770,'Fluvisols','Aw'),
('STE','Santa Elena',16.9167,-89.8994,160,'Fluvisols','Aw'),
('CUA','Cuilapa',14.2769,-90.2997,980,'Andosol','Cwa'),
('PAL','Palencia',14.6644,-90.3594,1390,'Andosol','Cwa'),
('ESQ','Esquipulas',14.5667,-89.3500,950,'Fluvisols','Aw'),
('SUM','Sumpango',14.6450,-90.7364,1860,'Andosol','Cwb'),
('CCH','San Pedro Carchá',15.4711,-90.3033,1280,'Andosol','Cwb')
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

-- Upsert sample crops data using MERGE to avoid duplicate key violations
MERGE agriculture.Crops AS target
USING (VALUES
-- Permanentes / perennes
('CAFE','Café','Coffee',18,24,70,90,10,32,'["4","5"]','["11","12","1"]','High',40,240,1,
 'Arbusto tropical de la familia Rubiaceae, cultivado por sus semillas, que se tuestan y muelen para preparar la bebida café. Prefiere climas templados y húmedos de altura.',
 'assets/CAFE.png'),
('BANANO','Banano','Banana',26,30,75,90,15,38,'["1","2","3","12"]','["1","2","3","12"]','High',50,365,1,
 'Planta herbácea perenne de la familia Musaceae. Prefiere zonas cálidas y húmedas bajas; frutos ricos en potasio en racimos.',
 'assets/BANANO.png'),
('PLATANO','Plátano','Plantain',22,28,70,85,15,35,'["1","2","3","12"]','["1","2","3","12"]','High',45,365,1,
 'Planta herbácea tropical, similar al banano pero cultivada en rangos algo más frescos; sus frutos se consumen cocidos.',
 'assets/PLATANO.png'),
('CARDAM','Cardamomo','Cardamom',20,25,70,85,12,32,'["3","4"]','["11","12"]','High',40,240,1,
 'Planta perenne de la familia Zingiberaceae, cultivada por sus cápsulas aromáticas que contienen semillas usadas como especia.',
 'assets/CARDAM.png'),
('CACAO','Cacao','Cocoa',22,28,75,90,15,35,'["5","6"]','["10","11","12"]','High',45,300,1,
 'Árbol tropical de la familia Malvaceae, originario de América, cuyo fruto contiene semillas empleadas para elaborar chocolate.',
 'assets/CACAO.png'),
('CANA','Caña de Azúcar','Sugar Cane',24,32,60,80,18,40,'["1","2","3"]','["1","2","3"]','High',55,365,1,
 'Planta gramínea tropical de tallos altos y jugosos, fuente principal de azúcar a nivel mundial.',
 'assets/CANA.png'),
('PALMA','Palma Africana','Oil Palm',24,32,70,85,18,38,'["5","6"]','["1","2","3","12"]','High',45,365,1,
 'Palmera originaria de África occidental, cultivada por sus frutos ricos en aceite vegetal.',
 'assets/PALMA.png'),
('HULE','Hule','Rubber',24,30,70,85,15,35,'["5","6"]','["1","2","3","12"]','High',40,365,1,
 'Árbol tropical de la familia Euphorbiaceae, cultivado por su látex, materia prima del caucho natural.',
 'assets/HULE.png'),
('AGUACAT','Aguacate','Avocado',18,28,60,80,10,34,'["1","2","3"]','["8","9","10"]','Medium',30,365,1,
 'Árbol perennifolio de la familia Lauraceae. Variedades de altura prefieren 18–25 °C, pero tolera hasta 28 °C en climas cálidos.',
 'assets/AGUACAT.png'),
('MANGO','Mango','Mango',24,32,60,75,12,38,'["2","3"]','["5","6"]','Medium',25,330,1,
 'Árbol tropical de la familia Anacardiaceae, cultivado por sus frutos carnosos, dulces y aromáticos.',
 'assets/MANGO.png'),
('NARANJ','Naranja','Orange',18,30,60,75,5,35,'["5","6"]','["11","12","1"]','Medium',30,365,1,
 'Árbol cítrico de la familia Rutaceae, cultivado por sus frutos redondos y jugosos, fuente importante de vitamina C.',
 'assets/NARANJ.png'),
('LIMON','Limón','Lemon/Lime',20,30,60,75,5,35,'["5","6"]','["11","12","1"]','Medium',30,365,1,
 'Árbol o arbusto cítrico de la familia Rutaceae, apreciado por sus frutos ácidos y aromáticos.',
 'assets/LIMON.png'),
('PINA','Piña','Pineapple',22,28,70,85,15,35,'["5","6"]','["1","2","3","12"]','High',35,360,1,
 'Planta tropical de la familia Bromeliaceae, de porte bajo, con frutos compuestos, jugosos y dulces.',
 'assets/PINA.png'),
('PAPAYA','Papaya','Papaya',24,32,65,80,12,36,'["5","6"]','["1","2","3","12"]','Medium',35,300,1,
 'Planta arbustiva tropical de la familia Caricaceae, con frutos grandes, carnosos y anaranjados.',
 'assets/PAPAYA.png'),
('GUAYABA','Guayaba','Guava',20,30,60,80,8,38,'["5","6"]','["10","11"]','Medium',25,300,1,
 'Arbusto o árbol pequeño de la familia Myrtaceae, originario de América tropical, con frutos aromáticos y ricos en vitamina C.',
 'assets/GUAYABA.png'),
('MACADA','Macadamia','Macadamia',18,25,60,80,8,32,'["5","6"]','["12","1"]','Medium',30,365,1,
 'Árbol perenne de la familia Proteaceae, originario de Australia, cultivado por sus nueces comestibles y aceitosas.',
 'assets/MACADA.png'),
('MARACUY','Maracuyá','Passion Fruit',20,28,60,85,10,35,'["6","7"]','["11","12"]','Medium',35,240,1,
 'Planta trepadora de la familia Passifloraceae, con frutos redondos, aromáticos y de pulpa ácida.',
 'assets/MARACUY.png'),
-- Cereales, leguminosas, raíces y tubérculos
('MAIZ','Maíz','Corn',20,30,50,70,8,38,'["5","6"]','["9","10"]','Medium',25,120,1,
 'Planta anual de la familia Poaceae, originaria de América, con tallos altos y mazorcas de granos ricos en almidón.',
 'assets/MAIZ.png'),
('ARROZ','Arroz','Rice',20,30,70,85,12,35,'["5","6"]','["10","11"]','High',50,150,1,
 'Cereal anual de la familia Poaceae, cultivado en campos inundados, base alimentaria en muchas culturas.',
 'assets/ARROZ.png'),
('SORGO','Sorgo','Sorghum',25,32,45,60,18,40,'["5","6"]','["9","10"]','Low',20,110,1,
 'Cereal resistente a la sequía, de la familia Poaceae, usado para grano, forraje y producción de alcohol.',
 'assets/SORGO.png'),
('TRIGO','Trigo','Wheat',15,25,50,70,5,30,'["11","12"]','["4","5"]','Medium',25,120,1,
 'Cereal anual de la familia Poaceae, fundamental para la producción de harina y pan.',
 'assets/TRIGO.png'),
('CEBADA','Cebada','Barley',10,24,50,70,4,28,'["11","12"]','["3","4"]','Low',20,110,1,
 'Cereal de ciclo corto, de la familia Poaceae, usado en alimentación y elaboración de cerveza.',
 'assets/CEBADA.png'),
('FRIJOL','Frijol','Bean',18,28,60,75,10,35,'["5","6"]','["8","9"]','Medium',20,90,1,
 'Planta anual de la familia Fabaceae, cultivada por sus semillas comestibles, fuente importante de proteína vegetal.',
 'assets/FRIJOL.png'),
('EJOTE','Ejote','Green Bean',18,28,60,80,10,35,'["9","10"]','["1","2"]','Medium',20,70,1,
 'Variedad de frijol cosechada por sus vainas verdes y tiernas, consumidas como verdura.',
 'assets/EJOTE.png'),
('ARVEJA','Arveja China','Snow Pea',12,22,60,80,5,28,'["9","10"]','["1","2"]','Medium',20,70,1,
 'Planta anual de la familia Fabaceae, cuyas vainas planas y semillas verdes se consumen frescas.',
 'assets/ARVEJA.png'),
('CHICHARO','Chícharo','Garden Pea',10,20,60,80,4,25,'["10","11"]','["2","3"]','Medium',20,90,1,
 'Planta anual de la familia Fabaceae, cultivada por sus semillas verdes y dulces, consumidas frescas o secas.',
 'assets/CHICHARO.png'),
('YUCA','Yuca','Cassava',25,30,65,85,15,38,'["5","6"]','["11","12"]','Medium',30,300,1,
 'Planta arbustiva tropical de la familia Euphorbiaceae, cultivada por sus raíces tuberosas ricas en almidón.',
 'assets/YUCA.png'),
('CAMOTE','Camote','Sweet Potato',20,30,65,80,12,35,'["5","6"]','["9","10"]','Medium',30,120,1,
 'Planta de la familia Convolvulaceae, cultivada por sus raíces comestibles de sabor dulce.',
 'assets/CAMOTE.png'),
('MALANGA','Malanga','Taro',20,30,70,90,12,35,'["5","6"]','["10","11"]','High',40,210,1,
 'Planta tropical de la familia Araceae, cultivada por sus cormos ricos en almidón.',
 'assets/MALANGA.png'),
('PAPA','Papa','Potato',15,20,65,80,5,28,'["10","11"]','["3","4"]','Medium',25,120,1,
 'Planta herbácea de la familia Solanaceae, originaria de los Andes, cultivada por sus tubérculos comestibles.',
 'assets/PAPA.png'),
-- Hortalizas y brassicas
('TOMATE','Tomate','Tomato',20,28,60,75,10,32,'["11","12"]','["3","4"]','Medium',30,90,1,
 'Planta anual de la familia Solanaceae, cultivada por sus frutos rojos, jugosos y ricos en licopeno.',
 'assets/TOMATE.png'),
('CHILEP','Chile Pimiento','Chili Pepper',20,30,55,75,10,35,'["11","12"]','["3","4"]','Medium',25,100,1,
 'Planta anual de la familia Solanaceae, cultivada por sus frutos picantes o dulces, de diversos colores.',
 'assets/CHILEP.png'),
('PIMIENT','Pimiento Morrón','Bell Pepper',20,30,55,75,10,35,'["11","12"]','["3","4"]','Medium',25,100,1,
 'Variedad de Capsicum annuum, de frutos grandes, carnosos y dulces, consumidos frescos o cocidos.',
 'assets/PIMIENT.png'),
('CEBOLL','Cebolla','Onion',15,30,55,75,8,35,'["10","11"]','["2","3"]','Medium',25,120,1,
 'Planta bienal de la familia Amaryllidaceae, cultivada por sus bulbos comestibles y aromáticos.',
 'assets/CEBOLL.png'),
('AJO','Ajo','Garlic',15,25,50,70,5,30,'["11","12"]','["3","4"]','Low',20,120,1,
 'Planta bulbosa de la familia Amaryllidaceae, apreciada por su sabor intenso y propiedades medicinales.',
 'assets/AJO.png'),
('BROCOLI','Brócoli','Broccoli',15,22,65,80,8,28,'["10","11"]','["2","3"]','Medium',25,75,1,
 'Planta anual de la familia Brassicaceae, cultivada por sus inflorescencias verdes y comestibles.',
 'assets/BROCOLI.png'),
('COLIFL','Coliflor','Cauliflower',15,22,65,80,8,28,'["10","11"]','["2","3"]','Medium',25,80,1,
 'Planta anual de la familia Brassicaceae, cultivada por sus cabezas blancas y compactas.',
 'assets/COLIFL.png'),
('LECHUG','Lechuga','Lettuce',12,20,60,75,5,25,'["9","10"]','["1","2"]','Low',15,60,1,
 'Planta anual de la familia Asteraceae, cultivada por sus hojas tiernas y comestibles, base de ensaladas.',
 'assets/LECHUG.png'),
('REPOLL','Repollo','Cabbage',15,22,65,80,8,25,'["10","11"]','["2","3"]','Medium',25,110,1,
 'Planta bienal de la familia Brassicaceae, cultivada por sus hojas compactas y comestibles.',
 'assets/REPOLL.png'),
('ZANAHO','Zanahoria','Carrot',15,25,55,75,5,28,'["10","11"]','["2","3"]','Medium',20,100,1,
 'Planta bienal de la familia Apiaceae, cultivada por su raíz comestible, rica en betacarotenos.',
 'assets/ZANAHO.png'),
('PEPINO','Pepino','Cucumber',20,30,60,80,12,35,'["11","12"]','["2","3"]','Medium',30,70,1,
 'Planta anual de la familia Cucurbitaceae, cultivada por sus frutos alargados y jugosos.',
 'assets/PEPINO.png'),
('CALABAZ','Calabacín','Zucchini',20,30,60,80,12,35,'["11","12"]','["2","3"]','Medium',25,60,1,
 'Planta anual de la familia Cucurbitaceae, de frutos verdes, tiernos y comestibles.',
 'assets/CALABAZ.png'),
-- Frutas y otros
('MELON','Melón','Melon',22,32,40,60,10,38,'["11","12"]','["2","3"]','Low',20,75,1,
 'Planta anual de la familia Cucurbitaceae, de frutos grandes, dulces y aromáticos.',
 'assets/MELON.png'),
('SANDIA','Sandía','Watermelon',22,30,40,60,10,38,'["11","12"]','["2","3"]','Low',20,75,1,
 'Planta anual de la familia Cucurbitaceae, de frutos grandes, pulpa roja y alto contenido de agua.',
 'assets/SANDIA.png'),
('PITAHAY','Pitahaya','Dragon Fruit',18,30,30,50,5,38,'["2","3"]','["6","7"]','Low',10,180,1,
 'Cactácea trepadora originaria de América, apreciada por sus frutos exóticos y nutritivos. Requiere humedad moderada y buen drenaje.',
 'assets/PITAHAY.png'),
('SESAMO','Ajonjolí','Sesame',24,32,40,60,10,40,'["5","6"]','["8","9"]','Low',15,110,1,
 'Planta anual de la familia Pedaliaceae, cultivada por sus semillas oleaginosas, pequeñas y nutritivas.',
 'assets/SESAMO.png'),
('MANI','Maní','Peanut',22,30,50,70,10,35,'["5","6"]','["8","9"]','Medium',20,120,1,
 'Planta anual de la familia Fabaceae, cuyas vainas se desarrollan bajo tierra y contienen semillas comestibles.',
 'assets/MANI.png'),


-- FRESA
('FRESA','Fresa','Strawberry',10,22,60,80,5,28,'["11","12","1"]','["3","4"]','Medium',25,120,1,
 'Planta herbácea perenne de la familia Rosaceae, cultivada por sus frutos rojos, jugosos y dulces. Prefiere climas templados y suelos bien drenados.',
 'assets/FRESA.png'),

-- MANZANA
('MANZANA','Manzana','Apple',5,20,50,75,-2,25,'["12","1"]','["6","7"]','Medium',35,240,1,
 'Árbol caducifolio de la familia Rosaceae, cultivado en el altiplano frío. Sus frutos son pomáceas dulces o ácidas, ampliamente consumidas frescas o procesadas.',
 'assets/MANZANA.png'),

-- PERA
('PERA','Pera','Pear',5,20,55,75,-2,25,'["12","1"]','["6","7"]','Medium',35,240,1,
 'Árbol caducifolio de la familia Rosaceae, cultivado en zonas frías de altura. Produce frutos jugosos y dulces, muy apreciados en fresco.',
 'assets/PERA.png'),

-- DURAZNO
('DURAZNO','Durazno','Peach',8,22,55,75,-2,28,'["12","1"]','["5","6"]','Medium',30,210,1,
 'Árbol frutal de la familia Rosaceae, cultivado en climas templados. Sus frutos son drupas carnosas y aromáticas, de gran importancia comercial en el altiplano.',
 'assets/DURAZNO.png'),

-- CIRUELA
('CIRUELA','Ciruela','Plum',8,22,55,75,-2,28,'["12","1"]','["5","6"]','Medium',30,210,1,
 'Árbol frutal de la familia Rosaceae, cultivado en climas templados y fríos. Sus frutos son drupas jugosas de sabor ácido-dulce.',
 'assets/CIRUELA.png'),

-- MANZANILLA (opcional medicinal, se produce en altiplano)
('MANZANI','Manzanilla','Chamomile',8,20,55,75,0,25,'["10","11"]','["2","3"]','Low',10,90,1,
 'Planta herbácea anual de la familia Asteraceae, usada en infusiones medicinales y aromáticas. Cultivada en huertos familiares de climas templados.',
 'assets/MANZANI.png')


) AS source (CropCode, CropNameSpanish, CropNameEnglish, OptimalTempMin, OptimalTempMax, 
OptimalHumidityMin, OptimalHumidityMax, StressTempMin, StressTempMax, PlantingMonths, HarvestMonths, WaterRequirement,WaterRequirementMmPerWeek, GrowthCycleDays, IsActive, Description, CropPicture)
ON target.CropCode = source.CropCode
WHEN MATCHED THEN
    UPDATE SET 
        CropNameSpanish = source.CropNameSpanish,
        CropNameEnglish = source.CropNameEnglish,
        OptimalTempMin = source.OptimalTempMin,
        OptimalTempMax = source.OptimalTempMax,
        OptimalHumidityMin = source.OptimalHumidityMin,
        OptimalHumidityMax = source.OptimalHumidityMax,
        StressTempMin = source.StressTempMin,
        StressTempMax = source.StressTempMax,
        PlantingMonths = source.PlantingMonths,
        HarvestMonths = source.HarvestMonths,
        WaterRequirement = source.WaterRequirement,
        WaterRequirementMmPerWeek = source.WaterRequirementMmPerWeek,
        GrowthCycleDays = source.GrowthCycleDays,
        IsActive = source.IsActive,
        Description = source.Description,
        CropPicture = source.CropPicture
WHEN NOT MATCHED THEN
    INSERT (CropCode, CropNameSpanish, CropNameEnglish, OptimalTempMin, OptimalTempMax, OptimalHumidityMin, OptimalHumidityMax, StressTempMin, StressTempMax, PlantingMonths, HarvestMonths, WaterRequirement, WaterRequirementMmPerWeek, GrowthCycleDays, IsActive, Description, CropPicture)
    VALUES (source.CropCode, source.CropNameSpanish, source.CropNameEnglish, source.OptimalTempMin, source.OptimalTempMax, source.OptimalHumidityMin, source.OptimalHumidityMax, source.StressTempMin, source.StressTempMax, source.PlantingMonths, source.HarvestMonths, source.WaterRequirement, source.WaterRequirementMmPerWeek, source.GrowthCycleDays, source.IsActive, source.Description, source.CropPicture);
GO

-- Upsert sample city-crops relationships using MERGE to avoid duplicate key violations
-- Guatemala City (Urbano, 1500m, Volcánico) - Mixed crops suitable for medium altitude
MERGE agriculture.CityCrops AS target
USING (VALUES
-- Ciudad de Guatemala (GUA)
('GUA','MAIZ',85,1,0,-5,'Cultivo base; buen rendimiento en época de lluvias'),
('GUA','FRIJOL',80,1,0,-5,'Asociado a maíz; bien con manejos en secano'),
('GUA','CAFE',75,0,-1,5,'Altitud aceptable; calidad mejora con sombra'),
('GUA','PAPA',70,0,-2,5,'Se maneja mejor en fajas más altas cercanas'),
('GUA','TOMATE',75,0,0,-10,'Muy productivo en época seca con riego'),
('GUA','CEBOLL',70,0,0,-10,'Buena ventana noviembre–marzo'),
('GUA','AGUACAT',65,0,0,0,'Variedades de altura; manejo de heladas leves'),
('GUA','CHILEP',72,0,0,-10,'Estable con riego y control de plagas'),
-- Mixco (MIX)
('MIX','MAIZ',85,1,-1,-5,'Zona templada alta; milpa tradicional'),
('MIX','FRIJOL',80,1,-1,-5,'Buena adaptación en laderas'),
('MIX','CAFE',78,0,-2,8,'Altura adecuada; requiere sombra'),
('MIX','PAPA',75,0,-3,8,'Clima fresco; buen tuberizado'),
('MIX','BROCOLI',80,0,-3,10,'Fresco de altura; ventana seca'),
('MIX','LECHUG',72,0,-3,5,'Época fría; calidad hoja'),
('MIX','AGUACAT',70,0,-1,0,'Variedades de altura'),
('MIX','CEBOLL',70,0,-1,-5,'Buen desempeño en seco'),
-- Villa Nueva (VIL)
('VIL','MAIZ',85,1,1,-5,'Calor moderado; buenos suelos coluviales'),
('VIL','FRIJOL',80,1,1,-5,'Ciclo corto; buena asociación'),
('VIL','TOMATE',78,0,2,-10,'Productivo con riego'),
('VIL','CHILEP',75,0,2,-10,'Buena ventana post-lluvias'),
('VIL','CEBOLL',70,0,1,-10,'Mejor en época seca'),
('VIL','AGUACAT',65,0,0,0,'Variedades adaptadas'),
('VIL','LECHUG',60,0,-1,-5,'Mejor en meses frescos'),
('VIL','PAPAYA',58,0,2,0,'Posible en sitios cálidos bajos'),
-- Amatitlán (AMA)
('AMA','MAIZ',85,1,1,-5,'Valle cálido templado'),
('AMA','FRIJOL',80,1,1,-5,'Tradicional; buen rendimiento'),
('AMA','TOMATE',80,0,2,-10,'Excelente con riego'),
('AMA','CEBOLL',72,0,1,-10,'Época seca'),
('AMA','AGUACAT',68,0,0,0,'Variedades medianas'),
('AMA','NARANJ',70,0,1,0,'Cítricos adaptados'),
('AMA','PEPINO',72,0,2,-10,'Rápido ciclo en seco'),
('AMA','CHILEP',74,0,2,-10,'Requiere manejo sanitario'),
-- Santa Catarina Pinula (SCP)
('SCP','MAIZ',82,1,0,-5,'Laderas templadas'),
('SCP','FRIJOL',78,1,0,-5,'Bien asociado a maíz'),
('SCP','CAFE',76,0,-2,8,'Altitud favorable'),
('SCP','BROCOLI',78,0,-3,10,'Ventana fría'),
('SCP','TOMATE',72,0,0,-10,'Seco con riego'),
('SCP','AGUACAT',68,0,-1,0,'De altura'),
('SCP','CEBOLL',70,0,0,-10,'Época seca'),
('SCP','LECHUG',70,0,-2,0,'Calidad en frío'),
-- San Miguel Petapa (SMP)
('SMP','MAIZ',85,1,1,-5,'Valle cálido'),
('SMP','FRIJOL',80,1,1,-5,'Asociación tradicional'),
('SMP','TOMATE',78,0,2,-10,'Productivo con riego'),
('SMP','CHILEP',75,0,2,-10,'Buena ventana seca'),
('SMP','CEBOLL',70,0,1,-10,'Época seca'),
('SMP','AGUACAT',64,0,0,0,'Posible en sitios altos del municipio'),
('SMP','PEPINO',72,0,2,-10,'Ciclo rápido'),
('SMP','LECHUG',60,0,0,-5,'Mejor en meses frescos'),
-- Palencia (PAL)
('PAL','MAIZ',82,1,0,-5,'Colinas templadas'),
('PAL','FRIJOL',78,1,0,-5,'Milpa estable'),
('PAL','PAPA',72,0,-2,5,'Zonas altas'),
('PAL','BROCOLI',74,0,-2,8,'Frío moderado'),
('PAL','TOMATE',72,0,0,-10,'Riego en seco'),
('PAL','AGUACAT',68,0,-1,0,'De altura'),
('PAL','CEBOLL',68,0,0,-10,'Ventana seca'),
('PAL','LECHUG',68,0,-2,0,'Época fría'),
-- Barberena (BAR)
('BAR','MAIZ',82,1,1,-5,'Meseta cálida'),
('BAR','FRIJOL',78,1,1,-5,'Ciclo corto'),
('BAR','TOMATE',76,0,2,-10,'Riego recomendado'),
('BAR','CHILEP',74,0,2,-10,'Ventana seca'),
('BAR','CEBOLL',70,0,1,-10,'Época seca'),
('BAR','AGUACAT',66,0,0,0,'Variedades medianas'),
('BAR','NARANJ',70,0,1,0,'Cítricos factibles'),
('BAR','LECHUG',60,0,0,-5,'Mejor en frío'),
-- Chicacao (CIC) ~1100 m
('CIC','MAIZ',84,1,1,-5,'Cálido subhúmedo'),
('CIC','FRIJOL',78,1,1,-5,'Bien adaptado'),
('CIC','CAFE',78,0,-1,8,'Altura adecuada'),
('CIC','AGUACAT',70,0,0,0,'De altura media'),
('CIC','TOMATE',74,0,1,-10,'Productivo con riego'),
('CIC','CEBOLL',70,0,0,-10,'Época seca'),
('CIC','NARANJ',70,0,1,0,'Cítricos posibles'),
('CIC','PAPAYA',62,0,2,0,'Zonas bajas cercanas'),
-- Cuilapa (CUA) ~980 m
('CUA','MAIZ',82,1,1,-5,'Meseta cálida'),
('CUA','FRIJOL',78,1,1,-5,'Milpa tradicional'),
('CUA','TOMATE',76,0,2,-10,'Riego en seco'),
('CUA','CHILEP',74,0,2,-10,'Buena ventana seca'),
('CUA','CEBOLL',70,0,1,-10,'Época seca'),
('CUA','AGUACAT',66,0,0,0,'Variedades medianas'),
('CUA','NARANJ',70,0,1,0,'Cítricos adaptados'),
('CUA','PEPINO',72,0,2,-10,'Ciclo rápido'),

/* ---------- Altiplano / Frío de altura (Cwb ~1500–2500 m) ---------- */
-- Quetzaltenango (QEZ)
('QEZ','CAFE',88,1,-3,10,'Cafetal de altura; alta calidad'),
('QEZ','PAPA',95,1,-5,10,'Óptimo para papa'),
('QEZ','BROCOLI',85,0,-4,12,'Clima fresco ideal'),
('QEZ','COLIFL',84,0,-4,12,'Frío estable'),
('QEZ','REPOLL',82,0,-4,10,'Buena cabeza'),
('QEZ','ZANAHO',80,0,-3,8,'Raíces de calidad'),
('QEZ','TRIGO',78,0,-4,5,'Templado frío'),
('QEZ','CEBADA',78,0,-5,5,'De altura; buen grano'),
-- Chimaltenango (CHM)
('CHM','CAFE',85,1,-3,10,'Cafetal de altura'),
('CHM','PAPA',88,1,-4,10,'Altiplano ideal'),
('CHM','BROCOLI',82,0,-3,12,'Hortaliza de frío'),
('CHM','COLIFL',80,0,-3,12,'Ventana fría'),
('CHM','REPOLL',78,0,-3,10,'Buena compactación'),
('CHM','ZANAHO',78,0,-3,8,'Raíces uniformes'),
('CHM','MAIZ',80,0,-2,-5,'Maíz de altura'),
('CHM','AGUACAT',70,0,-1,0,'De altura'),
-- Huehuetenango (HUE)
('HUE','CAFE',86,1,-3,12,'Perfil de taza reconocido'),
('HUE','PAPA',88,1,-5,10,'Altiplano alto'),
('HUE','BROCOLI',80,0,-4,12,'Idóneo en frío'),
('HUE','TRIGO',78,0,-4,5,'Cereal templado'),
('HUE','CEBADA',78,0,-5,5,'Altura marcada'),
('HUE','REPOLL',76,0,-3,10,'Cabeza firme'),
('HUE','ZANAHO',78,0,-3,8,'Raíz dulce'),
('HUE','AGUACAT',70,0,-1,0,'Variedades de altura'),
-- Antigua Guatemala (ANT)
('ANT','CAFE',90,1,-2,10,'Origen reconocido internacionalmente'),
('ANT','PAPA',82,0,-3,8,'Frío moderado'),
('ANT','BROCOLI',82,0,-3,10,'Excelente calidad de exportación'),
('ANT','COLIFL',80,0,-3,10,'Ventana fría'),
('ANT','REPOLL',78,0,-3,8,'Cabezas compactas'),
('ANT','ZANAHO',76,0,-2,8,'Raíces uniformes'),
('ANT','AGUACAT',72,0,-1,0,'Altura media'),
('ANT','ARVEJA',78,0,-3,8,'Arveja china de exportación'),
-- Totonicapán (TOT)
('TOT','PAPA',92,1,-5,10,'Altitud óptima'),
('TOT','BROCOLI',84,0,-4,12,'Frío ideal'),
('TOT','COLIFL',82,0,-4,12,'Hortaliza de invierno'),
('TOT','REPOLL',80,0,-4,10,'Buena compactación'),
('TOT','TRIGO',78,0,-4,5,'Cereal templado'),
('TOT','CEBADA',78,0,-5,5,'Altura marcada'),
('TOT','ZANAHO',78,0,-3,8,'Raíz de calidad'),
('TOT','CAFE',82,0,-3,12,'Café de altura'),
-- Sololá (SOL)
('SOL','CAFE',86,1,-3,12,'Laderas alrededor del lago'),
('SOL','PAPA',88,1,-5,10,'Clima frío'),
('SOL','BROCOLI',82,0,-4,12,'Hortaliza de frío'),
('SOL','COLIFL',80,0,-4,12,'Buena firmeza'),
('SOL','REPOLL',78,0,-3,10,'Cabeza densa'),
('SOL','ZANAHO',78,0,-3,8,'Raíz de calidad'),
('SOL','AGUACAT',70,0,-1,0,'De altura'),
('SOL','ARVEJA',78,0,-3,8,'Exportación'),
-- San Marcos (SMC)
('SMC','CAFE',86,1,-3,12,'Faldas volcánicas'),
('SMC','PAPA',88,1,-5,10,'Altura alta'),
('SMC','BROCOLI',82,0,-4,12,'Invierno fresco'),
('SMC','TRIGO',78,0,-4,5,'Templado'),
('SMC','CEBADA',78,0,-5,5,'Altitud marcada'),
('SMC','REPOLL',76,0,-3,10,'Cabeza compacta'),
('SMC','ZANAHO',76,0,-3,8,'Raíz dulce'),
('SMC','AGUACAT',70,0,-1,0,'Variedades de altura'),
-- Santa Cruz del Quiché (SCQ)
('SCQ','CAFE',84,1,-3,10,'Zonas aptas'),
('SCQ','PAPA',86,1,-4,10,'Frío de altura'),
('SCQ','BROCOLI',80,0,-3,12,'Hortaliza de invierno'),
('SCQ','REPOLL',78,0,-3,10,'Buena compactación'),
('SCQ','ZANAHO',76,0,-3,8,'Raíz consistente'),
('SCQ','TRIGO',76,0,-3,5,'Cereal templado'),
('SCQ','CEBADA',76,0,-4,5,'Altiplano'),
('SCQ','AGUACAT',68,0,-1,0,'De altura'),
-- Chichicastenango (CHC)
('CHC','CAFE',84,1,-3,10,'Café de altura'),
('CHC','PAPA',86,1,-4,10,'Clima frío'),
('CHC','BROCOLI',80,0,-3,12,'Ventana invernal'),
('CHC','REPOLL',78,0,-3,10,'Cabeza firme'),
('CHC','ZANAHO',76,0,-3,8,'Raíz uniforme'),
('CHC','TRIGO',76,0,-3,5,'Templado'),
('CHC','CEBADA',76,0,-4,5,'Altiplano'),
('CHC','AGUACAT',68,0,-1,0,'Variedades de altura'),
-- Patzún (PAT)
('PAT','CAFE',86,1,-3,10,'Café de altura'),
('PAT','PAPA',88,1,-4,10,'Altiplano'),
('PAT','BROCOLI',82,0,-3,12,'Hortaliza de frío'),
('PAT','REPOLL',80,0,-3,10,'Excelente compactación'),
('PAT','ZANAHO',78,0,-3,8,'Raíz de calidad'),
('PAT','TRIGO',76,0,-3,5,'Cereal templado'),
('PAT','CEBADA',76,0,-4,5,'Altura'),
('PAT','AGUACAT',70,0,-1,0,'De altura'),
-- Sumpango (SUM)
('SUM','CAFE',84,1,-3,10,'Altura media-alta'),
('SUM','PAPA',86,1,-4,10,'Frío'),
('SUM','BROCOLI',80,0,-3,12,'Invierno'),
('SUM','REPOLL',78,0,-3,10,'Cabeza compacta'),
('SUM','ZANAHO',76,0,-3,8,'Raíz firme'),
('SUM','TRIGO',76,0,-3,5,'Templado'),
('SUM','CEBADA',76,0,-4,5,'Altiplano'),
('SUM','AGUACAT',68,0,-1,0,'Variedades de altura'),
-- Santa Lucía Milpas Altas (SML)
('SML','CAFE',86,1,-3,10,'Café de altura'),
('SML','PAPA',86,1,-4,10,'Clima frío'),
('SML','BROCOLI',80,0,-3,12,'Hortaliza de frío'),
('SML','REPOLL',78,0,-3,10,'Buena cabeza'),
('SML','ZANAHO',76,0,-3,8,'Raíz uniforme'),
('SML','TRIGO',76,0,-3,5,'Templado'),
('SML','CEBADA',76,0,-4,5,'Alta'),
('SML','AGUACAT',70,0,-1,0,'De altura'),
-- San Raymundo (SRM)
('SRM','CAFE',84,1,-3,10,'Altura media'),
('SRM','PAPA',84,1,-4,10,'Frío moderado'),
('SRM','BROCOLI',78,0,-3,12,'Hortaliza de frío'),
('SRM','REPOLL',76,0,-3,10,'Compacta'),
('SRM','ZANAHO',74,0,-3,8,'Raíz consistente'),
('SRM','TRIGO',74,0,-3,5,'Templado'),
('SRM','CEBADA',74,0,-4,5,'Altiplano'),
('SRM','AGUACAT',68,0,-1,0,'Variedades de altura'),
-- San Pedro Carchá (CCH) ~1280 m, húmedo
('CCH','CARDAM',92,1,-2,15,'Zona cardamomera principal'),
('CCH','CAFE',86,1,-2,12,'Café bajo sombra'),
('CCH','CACAO',78,0,0,12,'Alta humedad'),
('CCH','BANANO',72,0,1,10,'Tropical húmedo'),
('CCH','PINA',70,0,1,8,'Fruta tropical'),
('CCH','PAPAYA',70,0,1,8,'Productiva con drenaje'),
('CCH','MAIZ',76,0,0,0,'Ciclos de lluvia'),
('CCH','FRIJOL',72,0,0,0,'Asociado a maíz'),

/* ---------- Costa Sur / Tierras Bajas Pacífico (Aw ~0–400 m) ---------- */
-- Escuintla (ESC)
('ESC','BANANO',95,1,3,10,'Tropical húmedo; excelente'),
('ESC','CANA',92,1,2,5,'Caña de alto potencial'),
('ESC','PALMA',85,0,2,8,'Palma aceitera competitiva'),
('ESC','ARROZ',80,0,2,10,'Con riego/inundación'),
('ESC','PAPAYA',78,0,2,5,'Frutal tropical'),
('ESC','PINA',76,0,2,5,'Suelos bien drenados'),
('ESC','MAIZ',72,1,3,0,'Adaptado a calor'),
('ESC','MANI',70,0,2,-5,'Buenas llanuras'),
-- Mazatenango (MAZ)
('MAZ','BANANO',90,1,3,8,'Tropical húmedo'),
('MAZ','CANA',88,1,2,5,'Caña competitiva'),
('MAZ','PALMA',82,0,2,8,'Palma posible'),
('MAZ','ARROZ',78,0,2,10,'Riego / inundación'),
('MAZ','PAPAYA',78,0,2,5,'Frutal'),
('MAZ','PINA',76,0,2,5,'Bien drenado'),
('MAZ','MAIZ',72,1,3,0,'Calor estable'),
('MAZ','MANI',70,0,2,-5,'Secano viable'),
-- Santa Lucía Cotzumalguapa (SLC)
('SLC','CANA',90,1,2,5,'Cinturón cañero'),
('SLC','BANANO',88,1,3,8,'Tropical'),
('SLC','PALMA',82,0,2,8,'Palma factible'),
('SLC','ARROZ',78,0,2,10,'Riego'),
('SLC','MAIZ',70,1,3,0,'Adaptado'),
('SLC','PAPAYA',76,0,2,5,'Frutal tropical'),
('SLC','PINA',74,0,2,5,'Suelos drenados'),
('SLC','MANGO',76,0,2,0,'Fruta de costa'),
-- Retalhuleu (RET)
('RET','CANA',90,1,2,5,'Alto rendimiento'),
('RET','BANANO',88,1,3,8,'Tropical'),
('RET','PALMA',82,0,2,8,'Palma en desarrollo'),
('RET','ARROZ',78,0,2,10,'Riego'),
('RET','MAIZ',72,1,3,0,'Adaptado a calor'),
('RET','MANI',72,0,2,-5,'Secano'),
('RET','PAPAYA',76,0,2,5,'Frutal'),
('RET','PINA',74,0,2,5,'Drenaje'),

/* ---------- Caribe / Petén (Af/Aw húmedo) ---------- */
-- Puerto Barrios (PUE) Af
('PUE','BANANO',90,1,2,12,'Caribe muy húmedo'),
('PUE','CACAO',88,1,0,15,'Excelente para cacao'),
('PUE','PLATANO',90,1,2,12,'Muy productivo'),
('PUE','ARROZ',80,0,2,12,'Arroz de baja altitud'),
('PUE','PAPAYA',78,0,2,8,'Frutal tropical'),
('PUE','PINA',76,0,2,8,'Buen drenaje'),
('PUE','YUCA',78,0,2,5,'Raíz tropical'),
('PUE','MANGO',72,0,2,0,'Frutal'),
-- Flores (FLO) Aw
('FLO','PALMA',86,1,2,8,'Palma aceitera en Petén'),
('FLO','MAIZ',78,1,2,0,'Grano básico'),
('FLO','FRIJOL',74,1,1,0,'Asociado a maíz'),
('FLO','YUCA',78,0,2,5,'Raíz tropical'),
('FLO','ARROZ',78,0,2,10,'Valles inundables'),
('FLO','MANGO',76,0,2,0,'Fruta'),
('FLO','PAPAYA',76,0,2,8,'Tropical'),
('FLO','PINA',74,0,2,8,'Drenaje'),
-- Santa Elena (STE) Aw
('STE','PALMA',86,1,2,8,'Palma aceitera'),
('STE','MAIZ',78,1,2,0,'Base alimentaria'),
('STE','FRIJOL',74,1,1,0,'Bien asociado'),
('STE','YUCA',78,0,2,5,'Raíz tropical'),
('STE','ARROZ',78,0,2,10,'Con riego'),
('STE','MANGO',76,0,2,0,'Fruta'),
('STE','PAPAYA',76,0,2,8,'Tropical'),
('STE','BANANO',76,0,2,10,'Húmedo'),

/* ---------- Oriente seco / Valles cálidos (Aw más seco) ---------- */
-- Zacapa (ZAC)
('ZAC','SESAMO',85,1,3,-5,'Ajonjolí en valle seco'),
('ZAC','MANI',82,1,3,-5,'Maní de secano'),
('ZAC','SORGO',80,1,3,-10,'Tolerante a sequía'),
('ZAC','MAIZ',76,1,2,-10,'Adaptado con manejo'),
('ZAC','FRIJOL',72,1,1,-10,'Ciclo corto'),
('ZAC','MANGO',76,0,2,0,'Frutal de calor'),
('ZAC','NARANJ',70,0,1,0,'Cítricos con riego'),
('ZAC','TOMATE',70,0,2,-10,'Riego indispensable'),
-- Chiquimula (CHQ)
('CHQ','SESAMO',84,1,3,-5,'Ajonjolí tradicional'),
('CHQ','MANI',80,1,3,-5,'Maní de secano'),
('CHQ','SORGO',78,1,3,-10,'Tolerante a sequía'),
('CHQ','MAIZ',75,1,2,-10,'Manejo de humedad'),
('CHQ','FRIJOL',72,1,1,-10,'Ciclo corto'),
('CHQ','MANGO',76,0,2,0,'Fruta de valle'),
('CHQ','NARANJ',70,0,1,0,'Cítricos con riego'),
('CHQ','TOMATE',68,0,2,-10,'Riego recomendado'),
-- Esquipulas (ESQ)
('ESQ','SESAMO',82,1,3,-5,'Ajonjolí'),
('ESQ','MANI',80,1,3,-5,'Maní'),
('ESQ','SORGO',78,1,3,-10,'Tolerante'),
('ESQ','MAIZ',75,1,2,-10,'Adaptado'),
('ESQ','FRIJOL',72,1,1,-10,'Corto'),
('ESQ','MANGO',74,0,2,0,'Frutal'),
('ESQ','NARANJ',70,0,1,0,'Cítricos'),
('ESQ','TOMATE',68,0,2,-10,'Riego'),
-- Jutiapa (JUT)
('JUT','SESAMO',82,1,2,-5,'Ajonjolí'),
('JUT','MANI',80,1,2,-5,'Maní de secano'),
('JUT','SORGO',78,1,2,-10,'Tolerante a sequía'),
('JUT','MAIZ',76,1,1,-10,'Adaptado'),
('JUT','FRIJOL',72,1,1,-10,'Asociado'),
('JUT','MANGO',74,0,2,0,'Fruta'),
('JUT','NARANJ',70,0,1,0,'Cítricos'),
('JUT','TOMATE',68,0,2,-10,'Riego'),
-- Sanarate (SAN)
('SAN','SESAMO',80,1,2,-5,'Ajonjolí'),
('SAN','MANI',78,1,2,-5,'Maní'),
('SAN','SORGO',78,1,2,-10,'Tolerante'),
('SAN','MAIZ',76,1,1,-10,'Adaptado'),
('SAN','FRIJOL',72,1,0,-10,'Corto'),
('SAN','MANGO',72,0,2,0,'Frutal'),
('SAN','NARANJ',68,0,1,0,'Cítricos'),
('SAN','TOMATE',68,0,2,-10,'Riego'),
-- Guastatoya (GST)
('GST','SESAMO',80,1,2,-5,'Ajonjolí'),
('GST','MANI',78,1,2,-5,'Maní'),
('GST','SORGO',78,1,2,-10,'Tolerante'),
('GST','MAIZ',76,1,1,-10,'Adaptado'),
('GST','FRIJOL',72,1,0,-10,'Corto'),
('GST','MANGO',72,0,2,0,'Fruta'),
('GST','NARANJ',68,0,1,0,'Cítricos'),
('GST','TOMATE',68,0,2,-10,'Riego'),

/* ---------- Valles templado-húmedos (Cwa) ---------- */
-- Jalapa (JAL)
('JAL','MAIZ',82,1,0,-5,'Templado subhúmedo'),
('JAL','FRIJOL',78,1,0,-5,'Milpa estable'),
('JAL','TOMATE',76,0,1,-10,'Riego en seco'),
('JAL','CHILEP',74,0,1,-10,'Ventana seca'),
('JAL','CEBOLL',70,0,0,-10,'Época seca'),
('JAL','AGUACAT',66,0,-1,0,'Variedades medianas'),
('JAL','NARANJ',70,0,0,0,'Cítricos posibles'),
('JAL','LECHUG',66,0,-2,0,'Mejor en invierno'),
-- Salamá (SAL)
('SAL','MAIZ',80,1,1,-5,'Valle cálido'),
('SAL','FRIJOL',76,1,1,-5,'Milpa tradicional'),
('SAL','SESAMO',76,0,2,-5,'Secano'),
('SAL','MANI',74,0,2,-5,'Secano'),
('SAL','MANGO',74,0,2,0,'Fruta de valle'),
('SAL','NARANJ',70,0,1,0,'Cítricos con riego'),
('SAL','TOMATE',70,0,1,-10,'Riego'),
('SAL','AGUACAT',66,0,0,0,'Variedades medianas'),

/* ---------- Húmedo montañoso (Am, Alta Verapaz) ---------- */
-- Cobán (COB)
('COB','CARDAM',95,1,-2,15,'Capital del cardamomo'),
('COB','CAFE',88,1,-2,12,'Café bajo sombra'),
('COB','CACAO',80,0,0,12,'Humedad alta'),
('COB','BANANO',76,0,1,10,'Tropical húmedo'),
('COB','PAPAYA',74,0,1,8,'Fruta tropical'),
('COB','PINA',72,0,1,8,'Drenaje y acidez'),
('COB','MAIZ',74,0,0,0,'Ciclo lluvioso'),
('COB','FRIJOL',70,0,0,0,'Asociado'),

/* ---------- Resto de altiplano templado ---------- */
-- San Juan Sacatepéquez (SJS)
('SJS','CAFE',80,1,-2,10,'Café de altura'),
('SJS','PAPA',82,1,-3,8,'Clima fresco'),
('SJS','BROCOLI',78,0,-3,10,'Hortaliza de frío'),
('SJS','REPOLL',76,0,-3,8,'Cabeza firme'),
('SJS','ZANAHO',74,0,-2,8,'Raíz uniforme'),
('SJS','MAIZ',78,0,-1,-5,'Maíz de altura'),
('SJS','FRIJOL',74,0,-1,-5,'Asociado'),
('SJS','AGUACAT',68,0,-1,0,'Variedades de altura'),
-- Santa Lucía Milpas Altas ya arriba (SML)
-- Jocotenango (JOC) ~1550 m
('JOC','CAFE',88,1,-2,10,'Café de Antigua'),
('JOC','PAPA',80,0,-3,8,'Altura media-alta'),
('JOC','BROCOLI',80,0,-3,10,'Hortaliza de frío'),
('JOC','REPOLL',78,0,-3,8,'Compacta'),
('JOC','ZANAHO',76,0,-2,8,'Raíz dulce'),
('JOC','AGUACAT',72,0,-1,0,'De altura'),
('JOC','ARVEJA',78,0,-3,8,'Exportación'),
('JOC','MAIZ',76,0,-1,-5,'Altura'),

-- HULE (Rubber) → zonas cálidas y húmedas (Costa Sur, Caribe, Petén)
('ESC','HULE',82,0,3,8,'Cultivo tropical, caucho natural'),
('RET','HULE',80,0,3,8,'Factible en tierras bajas húmedas'),
('PUE','HULE',78,0,2,10,'Alta humedad favorece látex'),

-- GUAYABA → clima tropical y subtropical, baja y media altitud
('AMA','GUAYABA',72,0,1,0,'Frutal tropical, buen sabor'),
('CIC','GUAYABA',74,0,1,0,'Producción local en huertos familiares'),
('PUE','GUAYABA',76,0,2,5,'Excelente adaptación caribeña'),

-- MACADA (Macadamia) → altura media, climas templados húmedos
('ANT','MACADA',74,0,-1,0,'Plantaciones presentes en Sacatepéquez'),
('CHM','MACADA',72,0,-2,0,'Altura media, suelos volcánicos'),
('TOT','MACADA',70,0,-2,0,'Factible en altiplano húmedo'),

-- MARACUY (Passion Fruit) → subtropical, zonas cálidas húmedas
('ESC','MARACUY',78,0,2,8,'Trepadora tropical, jugo'),
('COB','MARACUY',76,0,1,10,'Alta Verapaz, humedad favorable'),
('PUE','MARACUY',80,0,2,10,'Caribe, excelente adaptación'),

-- EJOTE (Green Bean) → zonas templadas, ciclo corto
('MIX','EJOTE',72,0,-2,0,'Asociado a hortalizas de altura'),
('SCP','EJOTE',70,0,-2,0,'Cultivo fresco de invierno'),
('QEZ','EJOTE',74,0,-3,0,'Ideal en clima frío medio'),

-- CHICHARO (Garden Pea) → frío de altura, similar a arveja
('TOT','CHICHARO',76,0,-4,5,'Arveja dulce en altiplano'),
('QEZ','CHICHARO',74,0,-3,5,'Bien adaptado en clima frío'),
('PAT','CHICHARO',72,0,-3,5,'Variedades de exportación'),

-- MALANGA (Taro) → zonas cálidas húmedas, raíces tropicales
('ESC','MALANGA',78,0,2,8,'Suelo húmedo, cultivo de raíz'),
('RET','MALANGA',76,0,2,8,'Tierras bajas, factible en inundables'),
('PUE','MALANGA',80,0,2,10,'Alta humedad caribeña'),

-- AJO (Garlic) → altiplano frío, ciclos de invierno
('TOT','AJO',72,0,-4,0,'Cultivo de frío, ciclo seco'),
('QEZ','AJO',74,0,-4,0,'Altitud óptima para ajo'),
('HUE','AJO',72,0,-3,0,'Valle frío, buen bulbo'),

-- PIMIENT (Bell Pepper) → similar a chile pimiento, altitud media/baja
('AMA','PIMIENT',74,0,1,-5,'Factible con riego en seco'),
('VIL','PIMIENT',72,0,2,-5,'Cultivo hortícola adaptable'),
('ESC','PIMIENT',76,0,3,-5,'Costa Sur, hortaliza bajo riego'),

-- SANDIA (Watermelon) → zonas cálidas secas y húmedas, baja altitud
('ESC','SANDIA',80,0,3,-5,'Fruta de verano en Costa Sur'),
('ZAC','SANDIA',74,0,3,-10,'Valle seco, tolera calor'),
('PUE','SANDIA',78,0,2,5,'Caribe, alto contenido de agua'),

-- PITAHAY (Dragon Fruit) → cactácea tropical, semiárida
('ZAC','PITAHAY',76,0,3,-10,'Adaptada a clima seco y cálido'),
('ESC','PITAHAY',78,0,3,-5,'Cultivo emergente en costa sur'),
('CHQ','PITAHAY',74,0,2,-10,'Valle seco oriente'),


/* ---------- Nuevos frutales de altura ---------- */
-- Quetzaltenango (QEZ)
('QEZ','FRESA',85,1,-3,5,'Clima frío ideal para fresa'),
('QEZ','MANZANA',88,1,-4,5,'Altiplano óptimo para manzana'),
('QEZ','PERA',86,0,-4,5,'Condiciones frías para pera'),
('QEZ','DURAZNO',84,0,-3,5,'Durazno de buena calidad en altura'),
('QEZ','CIRUELA',82,0,-3,5,'Ciruela en clima frío'),

-- Totonicapán (TOT)
('TOT','FRESA',84,1,-3,5,'Altura ideal para fresa'),
('TOT','MANZANA',88,1,-4,5,'Manzana en altiplano frío'),
('TOT','PERA',86,0,-4,5,'Pera cultivada en clima frío'),
('TOT','DURAZNO',84,0,-3,5,'Durazno adaptado a altura'),
('TOT','CIRUELA',82,0,-3,5,'Ciruela de buen sabor'),

-- Chimaltenango (CHM)
('CHM','FRESA',82,1,-3,5,'Zona productora importante de fresa'),
('CHM','MANZANA',85,1,-3,5,'Manzana de altura templada'),
('CHM','PERA',83,0,-3,5,'Pera en altiplano'),
('CHM','DURAZNO',82,0,-3,5,'Durazno de calidad'),
('CHM','CIRUELA',80,0,-2,5,'Ciruela adaptada'),

-- Huehuetenango (HUE)
('HUE','FRESA',80,1,-2,5,'Producción en microclimas fríos'),
('HUE','MANZANA',85,1,-3,5,'Manzana en altiplano'),
('HUE','PERA',83,0,-3,5,'Pera cultivada en zonas altas'),
('HUE','DURAZNO',82,0,-3,5,'Durazno adaptado'),
('HUE','CIRUELA',80,0,-2,5,'Ciruela de altura'),

-- Sololá (SOL)
('SOL','FRESA',82,1,-3,5,'Fresas alrededor del Lago Atitlán'),
('SOL','MANZANA',84,1,-3,5,'Manzana en clima frío'),
('SOL','PERA',82,0,-3,5,'Pera en laderas'),
('SOL','DURAZNO',80,0,-3,5,'Durazno de calidad'),
('SOL','CIRUELA',78,0,-2,5,'Ciruela adaptada'),

/* ---------- Cultivo medicinal ---------- */
-- Alta Verapaz (Cobán - COB)
('COB','MANZANI',76,0,-2,5,'Manzanilla en huertos familiares'),

-- Chimaltenango (CHM)
('CHM','MANZANI',78,0,-2,5,'Manzanilla cultivada en clima frío'),

-- Totonicapán (TOT)
('TOT','MANZANI',80,0,-3,5,'Manzanilla tradicional de altiplano')


) AS source (CityCode, CropCode, SuitabilityScore, IsPrimary, LocalTempAdjustment, LocalHumidityAdjustment, Notes)
ON target.CityCode = source.CityCode AND target.CropID = (SELECT CropID FROM agriculture.Crops WHERE CropCode = source.CropCode)
WHEN MATCHED THEN
    UPDATE SET 
        SuitabilityScore = source.SuitabilityScore,
        IsPrimary = source.IsPrimary,
        LocalTempAdjustment = source.LocalTempAdjustment,
        LocalHumidityAdjustment = source.LocalHumidityAdjustment,
        Notes = source.Notes
WHEN NOT MATCHED THEN
    INSERT (CityCode, CropID, SuitabilityScore, IsPrimary, LocalTempAdjustment, LocalHumidityAdjustment, Notes)
    VALUES (source.CityCode, (SELECT CropID FROM agriculture.Crops WHERE CropCode = source.CropCode), source.SuitabilityScore, source.IsPrimary, source.LocalTempAdjustment, source.LocalHumidityAdjustment, source.Notes);
GO

PRINT 'Post-deployment script completed successfully.';
PRINT 'Note: Run agriculture_migration.sql manually to normalize crop seasons data.';
GO
