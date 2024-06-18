-- Table Definition
CREATE TABLE weather.icons (
    ID INT,
    Icon VARCHAR(10),
    Main VARCHAR(50),
    Description_English VARCHAR(50),
    Description_Spanish VARCHAR(50),
    Image VARCHAR(50),
    Start_Color VARCHAR(7) NOT NULL, -- Hex color code for start of gradient
    End_Color VARCHAR(7) NOT NULL,   -- Hex color code for end of gradient
    PRIMARY KEY (ID, Icon)
);
