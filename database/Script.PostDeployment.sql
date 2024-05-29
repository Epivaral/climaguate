-- Insert statements for the cities
TRUNCATE TABLE weather.cities;

INSERT INTO weather.cities (CityName, Latitude, Longitude) VALUES
('Guatemala City', 14.6349, -90.5069),
('Quetzaltenango', 14.8347, -91.5180),
('Escuintla', 14.3050, -90.7850),
('San Juan Sacatepéquez', 14.7188, -90.6443),
('Villa Nueva', 14.5260, -90.5870),
('Mixco', 14.6333, -90.6064),
('Chimaltenango', 14.6611, -90.8208),
('Cobán', 15.4708, -90.3711),
('Huehuetenango', 15.3194, -91.4708),
('Mazatenango', 14.5347, -91.5050),
('Chiquimula', 14.8008, -89.5445),
('Antigua Guatemala', 14.5611, -90.7344);
GO