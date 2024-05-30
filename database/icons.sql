-- Table Definition
CREATE TABLE weather.icons (
    ID INT,
    Icon VARCHAR(10),
    Main VARCHAR(50),
    Description_English VARCHAR(50),
    Description_Spanish VARCHAR(50),
    Image VARCHAR(50),
    PRIMARY KEY (ID, Icon)
);
